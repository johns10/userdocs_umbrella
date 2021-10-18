defmodule UserDocsWeb.API.Resolvers.AnnotationType do

  alias UserDocs.Annotations.AnnotationType
  alias UserDocs.Annotations.Annotation

  def get_annotation_type!(%Annotation{ annotation_type: %AnnotationType{} = annotation_type }, _args, _resolution) do
    IO.puts("Get annotation_type call where the parent is annotation, and it has a preloaded annotation_type")
    { :ok, annotation_type }
  end
  def get_annotation_type!(%Annotation{ annotation_type: nil, annotation_type_id: nil }, _args, _resolution) do
    IO.puts("Get annotation_type call where the parent is annotation, and the annotation_type_id is nil")
    { :ok, nil }
  end

end
