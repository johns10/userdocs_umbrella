defmodule UserDocs.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  import ImageBase64Handler
  import UUID

  alias UserDocs.Repo

  alias UserDocs.Media.File

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

  @doc """
  Creates a file.

  ## Examples

      iex> create_file(%{field: value})
      {:ok, %File{}}

      iex> create_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file(attrs \\ %{}) do
    IO.puts("Create File")
    %File{}
    |> File.changeset(attrs)
    |> Repo.insert()
  end

  def encode_hash_create_file(attrs) do
    IO.puts("Encode, Hash, Create File 2")

    [ meta_text | [ encoded_image | _ ] ] = String.split(attrs["encoded_image"], ",")
    meta = image_meta(meta_text)

    file_name = UUID.uuid4() <> "." <> meta.image_type

    encoded_image
    |> base64ToImage(file_name)

    hash =
      Elixir.File.stream!(file_name, [], 2048)
      |> sha256()

    {:ok, file_stats} = Elixir.File.stat(file_name)

    file_attrs = %{
      filename: file_name,
      hash: hash,
      size: file_stats.size,
      content_type: meta.image_type
    }


    IO.inspect(file_attrs)

    %File{}
    |> File.changeset(file_attrs)
    |> Repo.insert()
    |> IO.inspect()
  end

  defp image_meta(meta) do
    [ "data:" <> type | [ encoding ]] = String.split(meta, ";")
    "image/" <> image_type = type

    %{
      type: type,
      encoding: encoding,
      image_type: image_type
    }
  end

  def sha256(chunks_enum) do
    chunks_enum
    |> Enum.reduce(
        :crypto.hash_init(:sha256),
        &(:crypto.hash_update(&2, &1))
    )
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
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
end
