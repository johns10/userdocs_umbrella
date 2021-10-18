defmodule UserDocsWeb.API.Resolvers.Annotation do

  alias UserDocs.Annotations.Annotation
  alias UserDocs.Automation.Step

  def get_annotation!(%Step{ annotation: %Annotation{} = annotation }, _args, _resolution) do
    IO.puts("Get annotation call where the parent is step, and it has a preloaded annotation")
    { :ok, annotation }
  end
  def get_annotation!(%Step{ annotation: nil, annotation_id: nil }, _args, _resolution) do
    IO.puts("Get annotation call where the parent is step, and the annotation_id is nil")
    { :ok, nil }
  end

end
