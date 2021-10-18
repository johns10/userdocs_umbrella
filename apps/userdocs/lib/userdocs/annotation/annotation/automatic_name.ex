defmodule UserDocs.Annotations.Annotation.Name do

  require Logger

  import UserDocs.Name

  alias UserDocs.Annotations.Annotation
  alias UserDocs.Elements.Element

  def execute(
    %Annotation{ annotation_type: %{ name: annotation_type_name } } = annotation,
    %Element{} = element
    ) do
    ""
    |> maybe_field(annotation, :label, ": ")
    |> field(annotation_type_name, " ")
    |> maybe_field(element, :name, "")
  end

  def execute(_, _) do
    ""
  end
end
