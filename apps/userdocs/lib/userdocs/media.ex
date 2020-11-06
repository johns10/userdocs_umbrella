defmodule UserDocs.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false

  require Logger

  alias UserDocs.Subscription

  alias UserDocs.Repo

  alias UserDocs.Media.File
  alias UserDocs.Media.FileHelpers
  alias UserDocs.Media.ScreenshotHelpers

  @doc """
  Returns the list of files.

  ## Examples

      iex> list_files()
      [%File{}, ...]

  """
  def list_files do
    Repo.all(File)
  end

  @doc """
  Gets a single file.

  Raises `Ecto.NoResultsError` if the File does not exist.

  ## Examples

      iex> get_file!(123)
      %File{}

      iex> get_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file!(id), do: Repo.get!(File, id)
  def get_file!(id, _params, _filters, state) do
    UserDocs.State.get!(state, id, :files, File)
  end

  @doc """
  Creates a file.

  ## Examples

      iex> create_file(%{field: value})
      {:ok, %File{}}

      iex> create_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file(attrs \\ %{}) do
    %File{}
    |> File.changeset(attrs)
    |> Repo.insert()
  end

  def create_file_and_screenshot(payload = %{ "encoded_image" => raw_encoded_image, "id" => step_id,
    "step_type" => %{ "name" => step_type_name }, "element" => element
    }) do
      IO.puts("create_file_and_screenshot")
    %{
      name: "Screenshot for step #{step_id}",
      file_id: nil,
      step_id: step_id,
    }
    |> upsert_screenshot()
    |> ScreenshotHelpers.handle_screenshot_upsert_results()
    |> ScreenshotHelpers.handle_screenshots_file(raw_encoded_image)
    |> ScreenshotHelpers.maybe_resize_image(step_type_name, element)
    |> ScreenshotHelpers.handle_file_disposition()
  end
  def create_file_and_screenshot(%{}), do: { :error, "Missing encoded image.  Failed to create file"}
  def create_file_and_screenshot(_) do
    raise(ArgumentError, message: "Passed an invalid variable to " <> Atom.to_string(__MODULE__))
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update_file(file, %{field: new_value})
      {:ok, %File{}}

      iex> update_file(file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file(%File{} = file, attrs) do
    file
    |> File.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete_file(file)
      {:ok, %File{}}

      iex> delete_file(file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file(%File{} = file) do
    Repo.delete(file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file changes.

  ## Examples

      iex> change_file(file)
      %Ecto.Changeset{data: %File{}}

  """
  def change_file(%File{} = file, attrs \\ %{}) do
    File.changeset(file, attrs)
  end

  alias UserDocs.Media.Screenshot

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
    |> maybe_preload_files(params[:file])
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

  defp maybe_preload_files(query, nil), do: query
  defp maybe_preload_files(query, _) do
    from(screenshots in query, preload: [:file])
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
