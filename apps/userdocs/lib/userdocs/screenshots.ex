defmodule UserDocs.Screenshots do
  @moduledoc """
  The Screenshot context.
  """

  import Ecto.Query, warn: false

  require Logger

  alias UserDocs.Repo


  alias UserDocs.Media.Screenshot

  def load_screenshots(state, opts) do
    StateHandlers.load(state, list_screenshots(%{}, opts[:filters]), Screenshot, opts)
  end
  @doc """
  Returns the list of screenshots.
  """
  def list_screenshots(_params \\ %{}, filters \\ %{}) do
    base_screenshots_query()
    |> maybe_filter_screenshots_by_version(filters[:version_id])
    |> maybe_filter_by_step_id(filters[:step_id])
    |> Repo.all()
  end

  defp maybe_filter_screenshots_by_version(query, nil), do: query
  defp maybe_filter_screenshots_by_version(query, version_id) do
    from(screenshot in query,
      left_join: step in assoc(screenshot, :step),
      left_join: process in assoc(step, :process),
      where: process.version_id == ^version_id,
      order_by: step.order
    )
  end

  defp maybe_filter_by_step_id(query, nil), do: query
  defp maybe_filter_by_step_id(query, step_id) do
    from(screenshot in query,
      where: screenshot.step_id == ^step_id
    )
  end

  defp base_screenshots_query(), do: from(screenshots in Screenshot)

  @doc """
  Gets a single screenshot.  Raises `Ecto.NoResultsError` if the Screenshot does not exist.
  """
  def get_screenshot!(id), do: Repo.get!(Screenshot, id)

  def get_screenshot_url(nil, _), do: { :no_screenshot, "" }
  def get_screenshot_url(%Ecto.Association.NotLoaded{}, _), do: { :not_loaded, "" }
  def get_screenshot_url(%Screenshot{ aws_screenshot: nil }, _), do: { :nofile, "" }
  def get_screenshot_url(%Screenshot{ aws_screenshot: aws_screenshot }, team) do
    region = team.aws_region
    bucket = team.aws_bucket
    path = aws_screenshot

    config =
      ExAws.Config.new(:s3)
      |> Map.put(:region, region)

    ExAws.S3.presigned_url(config, :get, bucket, path, virtual_host: true)
  end

  def get_url(nil, team), do: { :nofile, "" }
  def get_url(aws_key, team) do
    region = team.aws_region
    bucket = team.aws_bucket

    config =
      ExAws.Config.new(:s3)
      |> Map.put(:region, region)

    ExAws.S3.presigned_url(config, :get, bucket, aws_key, virtual_host: true)
  end

  def get_screenshot_by_step_id!(step_id) do
    Screenshot
    |> where([s], s.step_id == ^step_id)
    |> Repo.one!
  end

  @doc """
  Creates a screenshot.
  """
  def create_screenshot(attrs \\ %{}) do
    %Screenshot{}
    |> Screenshot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a screenshot.

  ## Examples

      iex> update_screenshot(screenshot, %{field: new_value})
      {:ok, %Screenshot{}}

      iex> update_screenshot(screenshot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_screenshot(%Screenshot{} = screenshot, attrs) do
    screenshot
    |> Screenshot.changeset(attrs)
    |> Repo.update()
  end
  def update_screenshot(%Screenshot{ base_64: _base_64 } = screenshot, attrs, %UserDocs.Users.Team{} = team) do
    screenshot
    |> Screenshot.changeset(attrs)
    |> diff_images(team)
    |> Repo.update()
  end

  def upsert_screenshot(attrs \\ %{}) do
    %Screenshot{}
    |> Screenshot.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end


  @doc """
  Deletes a screenshot.

  ## Examples

      iex> delete_screenshot(screenshot)
      {:ok, %Screenshot{}}

      iex> delete_screenshot(screenshot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_screenshot(%Screenshot{} = screenshot) do
    Repo.delete(screenshot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking screenshot changes.

  ## Examples

      iex> change_screenshot(screenshot)
      %Ecto.Changeset{data: %Screenshot{}}

  """
  def change_screenshot(%Screenshot{} = screenshot, attrs \\ %{}) do
    Screenshot.changeset(screenshot, attrs)
  end

  def apply_provisional_screenshot(%Screenshot{ aws_screenshot: production } = screenshot, team
  ) do
    names = %{ aws_provisional_screenshot: UUID.uuid4() <> ".png" }
    prepare_files(screenshot, names, team.aws_bucket, aws_opts(team))
    put_encoded_string_in_aws_object(File.read!(names.aws_provisional_screenshot), team, production)
    attrs = %{ aws_diff_screenshot: nil, aws_provisional_screenshot: nil }
    { :ok, screenshot } = update_screenshot(screenshot, attrs)
    screenshot
  end

  def diff_images(%{ data: %{ aws_screenshot: nil }} = changeset, team) do
    case Ecto.Changeset.get_change(changeset, :base_64) do
      nil -> changeset
      base_64 ->
        contents = Base.decode64!(base_64)
        file_name = file_name(changeset.data, :production)
        aws_path = put_encoded_string_in_aws_object(contents, team, path(file_name))
        IO.puts("AWS Path")
        IO.inspect(aws_path)
        Ecto.Changeset.put_change(changeset, :aws_screenshot, aws_path)
    end
  end
  def diff_images(%{ data: %{ aws_screenshot: _aws_screenshot }} = changeset, team) do
    case Ecto.Changeset.get_change(changeset, :base_64) do
      nil -> changeset
      base_64 ->
        state = %{
          aws: file_name(changeset.data, :production),
          original: UUID.uuid4() <> ".png",
          updated: UUID.uuid4() <> ".png",
          diff: UUID.uuid4() <> ".png",
          opts: aws_opts(team),
          bucket: team.aws_bucket,
          base_64: base_64,
          team: team,
          score: nil
        }

        prepare_aws_file(state)
        |> score_files()
        |> handle_changes(changeset)
        |> delete_files(state)
    end
  end

  def prepare_files(screenshot, names, bucket, opts) do
    Enum.each(names, fn({ field, file_name }) ->
      aws_key = Map.get(screenshot, field)
      IO.inspect(opts)
      IO.puts(aws_key)
      IO.puts(file_name)
      case ExAws.S3.download_file(bucket, aws_key, file_name) |> ExAws.request(opts) do
        { :ok, done } -> true
        e -> raise("#{__MODULE__}.prepare_all_files failed because #{e}")
      end
    end)
  end

  def prepare_aws_file(%{ aws: aws, original: original, updated: updated,
    bucket: bucket, base_64: base_64, opts: opts } = state
  ) do
    path = "screenshots/" <> aws
    case ExAws.S3.download_file(bucket, path, original) |> ExAws.request(opts) do
      { :ok, :done} ->
        File.write(updated, Base.decode64!(base_64))
        state
      _ -> raise("#{__MODULE__}.diff_images failed")
    end
  end

  def score_files(%{ original: original, updated: updated, diff: diff } = state) do
    args = ["compare", "-metric", "PSNR", original, updated, diff ]

    case System.cmd("magick", args, [ stderr_to_stdout: true ]) do
      { score, 1 } -> Map.put(state, :score, score)
      e -> raise("#{__MODULE__}.diff_images failed because #{e}")
    end
  end

  def handle_changes(%{ score: score, updated: updated, team: team } = state, changeset) do
    case score do
      "inf" -> changeset
      _ ->
        IO.puts("The file is different, creating provisional and diff")
        provisional_file_name = file_name(changeset.data, :provisional)
        put_encoded_string_in_aws_object(File.read!(updated), team, path(provisional_file_name))
        diff_file_name = file_name(changeset.data, :diff)
        put_encoded_string_in_aws_object(File.read!(updated), team, path(diff_file_name))
        changeset
        |> Ecto.Changeset.put_change(:aws_provisional_screenshot, path(provisional_file_name))
        |> Ecto.Changeset.put_change(:aws_diff_screenshot, path(diff_file_name))
    end
  end

  def delete_files(changeset, %{ original: original, updated: updated, diff: diff }) do
    File.rm(original)
    File.rm(updated)
    File.rm(diff)
    changeset
  end

  def put_encoded_string_in_aws_object(contents, team, path) do
    opts = aws_opts(team)
    bucket = team.aws_bucket

    case ExAws.S3.put_object(bucket, path, contents) |> ExAws.request(opts) do
      { :ok, _response } -> path
      _ -> raise("#{__MODULE__}.put_encoded_string_in_aws_object failed")
    end
  end

  def aws_opts(team) do
    [
      region: team.aws_region,
      access_key_id: team.aws_access_key_id,
      secret_access_key: team.aws_secret_access_key
    ]
  end

  defp path(file_name) do
    "screenshots/" <> file_name
  end

  defp file_name(screenshot, :diff) do
    to_string(screenshot.id)
    <> "-diff.png"
  end
  defp file_name(screenshot, :provisional) do
    to_string(screenshot.id)
    <> "-provisional.png"
  end
  defp file_name(screenshot, :production) do
    to_string(screenshot.id)
    <> ".png"
  end
end
