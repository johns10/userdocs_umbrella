defmodule UserDocs.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false

  require Logger

  alias UserDocs.Subscription

  alias UserDocs.Repo

  alias UserDocs.Media.File
  alias UserDocs.Media.ScreenshotHelpers


  alias UserDocs.Media.Screenshot

  def load_screenshots(state, opts) do
    StateHandlers.load(state, list_screenshots(), Screenshot, opts)
  end
  @doc """
  Returns the list of screenshots.

  ## Examples

      iex> list_screenshots()
      [%Screenshot{}, ...]

  """
  def list_screenshots(params \\ %{}, filters \\ %{}) do
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
  Gets a single screenshot.

  Raises `Ecto.NoResultsError` if the Screenshot does not exist.

  ## Examples

      iex> get_screenshot!(123)
      %Screenshot{}

      iex> get_screenshot!(456)
      ** (Ecto.NoResultsError)

  """
  def get_screenshot!(id), do: Repo.get!(Screenshot, id)

  def get_screenshot_url(nil), do: { :no_screenshot, "" }
  def get_screenshot_url(%Ecto.Association.NotLoaded{}), do: { :not_loaded, "" }
  def get_screenshot_url(%Screenshot{ aws_file: nil }), do: { :nofile, "" }
  def get_screenshot_url(%Screenshot{ aws_file: aws_file }) do
    region =
      Application.get_env(:userdocs, :ex_aws)
      |> Keyword.get(:region)

    bucket =
      Application.get_env(:userdocs, :waffle)
      |> Keyword.get(:bucket)

    config =
      ExAws.Config.new(:s3)
      |> Map.put(:region, region)

    uploads_dir =
      Application.get_env(:userdocs, :userdocs_s3)
      |> Keyword.get(:uploads_dir)

    path = uploads_dir <> "/" <> aws_file.file_name

    ExAws.S3.presigned_url(config, :get, bucket, path, virtual_host: true)
  end

  @doc """
  Creates a screenshot.

  ## Examples

      iex> create_screenshot(%{field: value})
      {:ok, %Screenshot{}}

      iex> create_screenshot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_screenshot(attrs \\ %{}) do
    %Screenshot{}
    |> Screenshot.changeset(attrs)
    |> Repo.insert()
    |> Subscription.broadcast("screenshot", "create")
  end

  def create_aws_file_and_screenshot(%{ "encoded_image" => raw_encoded_image, "id" => step_id,
    "step_type" => %{ "name" => step_type_name }, "element" => element
    }) do
      IO.puts("create_file_and_screenshot for step #{step_id}")
    %{
      name: "Screenshot for step #{step_id}",
      step_id: step_id,
    }
    |> get_or_insert_screenshot(step_id)
    |> ScreenshotHelpers.handle_screenshot_upsert_results()
    |> ScreenshotHelpers.save_file(raw_encoded_image)
    |> ScreenshotHelpers.maybe_resize_image(step_type_name, element)
    |> ScreenshotHelpers.update_screenshot()
  end
  def create_file_and_screenshot(%{}), do: { :error, "Missing encoded image.  Failed to create file"}
  def create_file_and_screenshot(_) do
    raise(ArgumentError, message: "Passed an invalid variable to " <> Atom.to_string(__MODULE__))
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
    |> Subscription.broadcast("screenshot", "update")
  end
  def update_screenshot(%Ecto.Changeset{} = screenshot) do
    Repo.update(screenshot)
    |> Subscription.broadcast("screenshot", "update")
  end

  def get_or_insert_screenshot(attrs, step_id) do
    try do
      { :ok, get_screenshot_by_step_id!(step_id) }
    rescue
      Ecto.NoResultsError ->
        create_screenshot(attrs)
    end
  end

  def get_screenshot_by_step_id!(step_id) do
    Screenshot
    |> where([s], s.step_id == ^step_id)
    |> Repo.one!
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
end
