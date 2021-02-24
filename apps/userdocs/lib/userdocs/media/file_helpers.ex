defmodule UserDocs.Media.FileHelpers do

  import ImageBase64Handler


  @dev_path "apps/userdocs_web/assets/static/images/"
  @prod_path "apps/userdocs_web/priv/static/"

  def encode_hash_save_file(raw, file_name \\ nil) do
    prepare_image_map(raw)
    |> add_file_name_to_map(file_name)
    |> save_file_from_map()
    |> add_hash_to_map()
    |> add_size_to_map()
    |> prepare_file_attrs()
  end

  defp prepare_image_map(raw) do
    [ meta_text | [ encoded_image | _ ] ] = String.split(raw, ",")

    %{
      meta: image_meta(meta_text),
      encoded_image: encoded_image
    }
  end

  defp add_file_name_to_map(image, nil) do
    Map.put(image, :file_name, file_name(image.meta.image_type))
  end
  defp add_file_name_to_map(image, file_name) do
    Map.put(image, :file_name, file_name)
  end

  defp file_name(type) do
    UUID.uuid4() <> "." <> type
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

  defp save_file_from_map(image) do
    try do
      save_file(image.encoded_image, image.file_name)
    rescue
      error -> raise(File.Error, message: error)
    end
    image
  end

  defp save_file(image, file_name) do
    path =
      if Mix.env() in [:dev, :test] do
        @dev_path
      else
        @prod_path
      end

    image
    |> base64ToImage(path <> file_name)
  end

  defp add_hash_to_map(image) do
    Map.put(image, :hash, hash(image.file_name))
  end

  defp hash(file_name) do
    path =
      if Mix.env() in [:dev, :test] do
        @dev_path
      else
        @prod_path
      end

    Elixir.File.stream!(path <> file_name, [], 2048)
    |> sha256()
  end

  defp add_size_to_map(image) do
    Map.put(image, :size, size(image.file_name))
  end

  defp size(file_name) do
    path =
      if Mix.env() in [:dev, :test] do
        @dev_path
      else
        @prod_path
      end

    {:ok, file_stats} = Elixir.File.stat(path <> file_name)
    file_stats.size
  end

  defp prepare_file_attrs(image) do
    %{
      filename: image.file_name,
      hash: image.hash,
      size: image.size,
      content_type: image.meta.image_type
    }
  end

  defp sha256(chunks_enum) do
    chunks_enum
    |> Enum.reduce(:crypto.hash_init(:sha256), &(:crypto.hash_update(&2, &1)))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end
end
