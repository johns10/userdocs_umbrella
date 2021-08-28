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

  def get_screenshot_url(nil, _), do: {:no_screenshot, ""}
  def get_screenshot_url(%Ecto.Association.NotLoaded{}, _), do: {:not_loaded, ""}
  def get_screenshot_url(%Screenshot{aws_screenshot: nil}, _), do: {:nofile, ""}
  def get_screenshot_url(%Screenshot{aws_screenshot: aws_screenshot}, team) do
    region = team.aws_region
    bucket = team.aws_bucket
    path = aws_screenshot

    config =
      ExAws.Config.new(:s3)
      |> Map.put(:region, region)

    ExAws.S3.presigned_url(config, :get, bucket, path, virtual_host: true)
  end

  def get_screenshot_status(%Screenshot{aws_screenshot: _, aws_provisional_screenshot: nil, aws_diff_screenshot: nil}), do: :ok
  def get_screenshot_status(%Screenshot{aws_screenshot: _, aws_provisional_screenshot: _, aws_diff_screenshot: _}), do: :warn
  def get_screenshot_status(%Screenshot{}), do: nil
  def get_screenshot_status(nil), do: nil

  def get_url(nil, _team), do: {:nofile, ""}
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
  def create_screenshot(attrs \\ %{})
  def create_screenshot(%{step_id: step_id, base64: _} = attrs) do
    result = %Screenshot{}
    |> Screenshot.changeset(%{step_id: step_id})
    |> Repo.insert()

    case result do
      {:ok, screenshot} -> update_screenshot(screenshot, attrs)
      result -> result
    end
  end
  def create_screenshot(attrs) do
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
    |> maybe_change_aws_filename()
    |> Repo.update()
  end
  def update_screenshot(%Screenshot{base64: _base64} = screenshot, attrs, %UserDocs.Users.Team{} = _team) do
    screenshot
    |> Screenshot.changeset(attrs)
    |> Repo.update()
  end

  def upsert_screenshot(attrs \\ %{}) do
    %Screenshot{}
    |> Screenshot.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def maybe_change_aws_filename(%{data: %{aws_screenshot: nil}} = changeset), do: changeset
  def maybe_change_aws_filename(%{data: %{aws_screenshot: current_aws_path, id: id}} = changeset) when is_integer(id) do
    current_file_name = unpath(current_aws_path)
    {:ok, screenshot} = Ecto.Changeset.apply_action(changeset, :update)
    new_file_name = file_name(screenshot, :production)
    if current_file_name != new_file_name do
      new_path = path(new_file_name)
      team = UserDocs.Users.get_screenshot_team!(id)
      {:ok, dest_path} = rename_aws_object(current_aws_path, new_path, team)
      Ecto.Changeset.put_change(changeset, :aws_screenshot, dest_path)
    else
      changeset
    end
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

  def apply_provisional_screenshot(%Screenshot{aws_screenshot: production} = screenshot, team) do
    names = %{aws_provisional_screenshot: "./tmp/" <> UUID.uuid4() <> ".png"}
    prepare_files(screenshot, names, team.aws_bucket, aws_opts(team))
    put_encoded_string_in_aws_object(File.read!(names.aws_provisional_screenshot), team, production)
    attrs = %{aws_diff_screenshot: nil, aws_provisional_screenshot: nil}
    {:ok, screenshot} = update_screenshot(screenshot, attrs)
    Enum.each(names, fn({_, file_name}) -> File.rm(file_name) end)
    screenshot
  end

  def prepare_files(screenshot, names, bucket, opts) do
    Enum.each(names, fn({field, file_name}) ->
      aws_key = Map.get(screenshot, field)
      case ExAws.S3.download_file(bucket, aws_key, file_name) |> ExAws.request(opts) do
        {:ok, _} -> true
        e -> raise("#{__MODULE__}.prepare_all_files failed because #{e}")
      end
    end)
  end

  def reject_provisional_screenshot(%Screenshot{} = screenshot) do
    attrs = %{aws_diff_screenshot: nil, aws_provisional_screenshot: nil}
    {:ok, screenshot} = update_screenshot(screenshot, attrs)
    screenshot
  end

  def create_aws_screenshot(%{data: _data, changes: %{base64: base64}} = changeset) do
    case Ecto.Changeset.get_field(changeset, :step_id) do
      nil -> throw("Screenshot has no step id")
      step_id ->
        team = UserDocs.Users.get_step_team!(step_id)
        contents = Base.decode64!(base64)
        file_name = file_name(changeset, :production)
        aws_path = put_encoded_string_in_aws_object(contents, team, path(file_name))
        Ecto.Changeset.put_change(changeset, :aws_screenshot, aws_path)
    end
  end
  def update_aws_screenshot(%{data: %{aws_screenshot: screenshot_path}, changes: %{base64: base64}} = changeset) do
    case Ecto.Changeset.get_field(changeset, :step_id) do
      nil -> throw("Screenshot has no step id")
      step_id ->
        team = UserDocs.Users.get_step_team!(step_id)
        temp_dir = maybe_create_temp_dir()
        state = %{
          aws: screenshot_path,
          original: temp_dir |> Path.join(UUID.uuid4() <> ".png"),
          updated: temp_dir |> Path.join(UUID.uuid4() <> ".png"),
          diff: temp_dir |> Path.join(UUID.uuid4() <> ".png"),
          opts: aws_opts(team),
          bucket: team.aws_bucket,
          base64: base64,
          team: team,
          score: nil
        }

        prepare_aws_file(state)
        |> ping_files()
        |> score_files()
        |> handle_changes(changeset)
        |> delete_files(state)

      end
  end

  def maybe_create_temp_dir() do
    priv_dir =
      if Mix.env() in [:test] do
        :code.priv_dir(:userdocs)
      else
        :code.priv_dir(:userdocs_web)
      end

    {:ok, dirs} = priv_dir |> File.ls()
    if "tmp" not in dirs do
      :ok = File.mkdir(priv_dir |> Path.join("tmp"))
    end
    priv_dir |> Path.join("tmp")
  end

  def prepare_aws_file(%{aws: aws_path, original: original, updated: updated,
    bucket: bucket, base64: base64, opts: opts} = state
  ) do
    case ExAws.S3.download_file(bucket, aws_path, original) |> ExAws.request(opts) do
      {:ok, :done} ->
        File.write(updated, Base.decode64!(base64))
        state
      {:error, "error downloading file"} ->
        File.write(original, "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAFiUAABYlAUlSJPAAAAAMSURBVBhXY/j//z8ABf4C/qc1gYQAAAAASUVORK5CYII=")
        File.write(updated, Base.decode64!(base64))
        state
      {:error, reason} ->
        Logger.error("prepare_aws failed because: #{reason}")
        raise("#{__MODULE__}.prepare_aws_file failed because: #{reason}") #TODO: More permanent fix
        state
    end
  end

  def ping_files(%{original: original, updated: updated, diff: _diff} = state) do
    r = System.cmd("identify", ["-ping", "-format", "%w %h", Path.absname(original)], [stderr_to_stdout: true])

    r2 = System.cmd("identify", ["-ping", "-format", "%w %h", Path.absname(updated)], [stderr_to_stdout: true])

    case r == r2 do
      false -> Map.put(state, :score, "size_difference")
      true -> state
    end
  end

  def score_files(%{score: "size_difference"} = state), do: state
  def score_files(%{original: original, updated: updated, diff: diff} = state) do
    args = [
      "-metric", "PSNR",
      Path.absname(original),
      Path.absname(updated),
      Path.absname(diff)
    ]

    case System.cmd("compare", args, [stderr_to_stdout: true]) do
      {score, 1} -> Map.put(state, :score, score)
      {score, 0} -> Map.put(state, :score, score)
      {"compare: image widths or heights differ" <> _, 2} ->
        Map.put(state, :score, "size_difference")
      :enoent -> raise("It's very likely you're not calling magick correctly, or your files aren't created correctly.")
      e ->
        raise("#{__MODULE__}.diff_images failed because #{inspect(e)}")
    end
  end

  def handle_changes(%{score: score, diff: diff, updated: updated, team: team}, changeset) do
    case score do
      "inf" -> changeset
      0 -> changeset
      "0" -> changeset
      "failed" -> create_aws_screenshot(changeset)
      "size_difference" ->
        Logger.info("There was a size difference")
        provisional_file_name = file_name(changeset, :provisional)
        put_encoded_string_in_aws_object(File.read!(updated), team, path(provisional_file_name))
        changeset
        |> Ecto.Changeset.put_change(:aws_provisional_screenshot, path(provisional_file_name))
      score ->
        Logger.info("Image Comparison score is " <> to_string(score))
        provisional_file_name = file_name(changeset, :provisional)
        put_encoded_string_in_aws_object(File.read!(updated), team, path(provisional_file_name))
        diff_file_name = file_name(changeset, :diff)
        put_encoded_string_in_aws_object(File.read!(diff), team, path(diff_file_name))

        changeset
        |> Ecto.Changeset.put_change(:aws_provisional_screenshot, path(provisional_file_name))
        |> Ecto.Changeset.put_change(:aws_diff_screenshot, path(diff_file_name))
    end
  end

  def delete_files(changeset, %{original: original, updated: updated, diff: diff}) do
    File.rm(original)
    File.rm(updated)
    File.rm(diff)
    changeset
  end

  def put_encoded_string_in_aws_object(contents, team, path) do
    opts = aws_opts(team)
    bucket = team.aws_bucket

    case ExAws.S3.put_object(bucket, path, contents) |> ExAws.request(opts) do
      {:ok, _response} -> path
      e -> raise("#{__MODULE__}.put_encoded_string_in_aws_object failed because #{e}")
    end
  end

  def rename_aws_object(src_path, dest_path, team) do
    opts = aws_opts(team)
    case ExAws.S3.put_object_copy(team.aws_bucket, dest_path, team.aws_bucket, src_path, opts) |> ExAws.request(opts) do
      {:ok, _response} ->
        ExAws.S3.delete_object(team.aws_bucket, src_path) |> ExAws.request(opts)
        {:ok, dest_path}
      e ->
        Logger.error("#{__MODULE__}.rename_aws_object failed because #{inspect(e)}")
        {:ok, dest_path}
    end
  end

  def aws_opts(team) do
    [
      region: team.aws_region,
      access_key_id: team.aws_access_key_id,
      secret_access_key: team.aws_secret_access_key
    ]
  end

  @screenshots_directory "screenshots"
  def path(file_name) do
    @screenshots_directory <> "/" <> file_name
  end
  def unpath(path) do
    @screenshots_directory <> "/" <> file_name = path
    file_name
  end

  def file_name(screenshot, :diff), do: file_name(screenshot) <> "-diff.png"
  def file_name(screenshot, :provisional), do: file_name(screenshot) <> "-provisional.png"
  def file_name(screenshot, :production), do: file_name(screenshot) <> ".png"
  defp file_name(%Ecto.Changeset{} = changeset) do
    case Ecto.Changeset.get_field(changeset, :name, nil) do
      nil -> case Ecto.Changeset.get_field(changeset, :id, nil) do
        nil -> UUID.uuid4()
        id -> Integer.to_string(id)
  end
      name -> name
  end
  end
  defp file_name(%Screenshot{name: nil, id: nil}), do: UUID.uuid4()
  defp file_name(%Screenshot{name: nil, id: id}) when is_integer(id), do: Integer.to_string(id)
  defp file_name(%Screenshot{name: name}), do: name

end
