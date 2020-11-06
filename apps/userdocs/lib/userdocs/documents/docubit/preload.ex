defmodule UserDocs.Documents.Docubit.Preload do

  alias UserDocs.Documents
  alias UserDocs.Media
  alias UserDocs.Web

  def apply(docubit, state) do
    { docubit, state }
    |> maybe_preload_content()
    |> maybe_preload_file()
    |> maybe_preload_through_annotation()
    |> return_docubit()
  end

  defp maybe_preload_content({%{ content_id: nil } = docubit, state}), do: { docubit, state }
  defp maybe_preload_content({%{ content_id: content_id } = docubit, state}
  ) when is_integer(content_id) do
    content = Documents.get_content!(content_id, %{}, %{}, state)
    { Map.put(docubit, :content, content), state }
  end
  defp maybe_preload_file({%{ file_id: nil } = docubit, state}), do: { docubit, state }
  defp maybe_preload_file({%{ file_id: file_id } = docubit, state}
  ) when is_integer(file_id) do
    file = Media.get_file!(file_id, %{}, %{}, state)
    { Map.put(docubit, :file, file), state }
  end

  defp maybe_preload_through_annotation({%{ through_annotation_id: nil } = docubit, state}), do: { docubit, state }
  defp maybe_preload_through_annotation({%{ through_annotation_id: annotation_id } = docubit, state}
  ) when is_integer(annotation_id) do
    annotation = Web.get_annotation!(annotation_id, %{}, %{}, state)
    { Map.put(docubit, :through_annotation, annotation), state}
  end

  defp return_docubit({docubit, _}), do: docubit

end
