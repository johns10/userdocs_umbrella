defmodule UserDocs.Web.Annotation.Name do

  require Logger

  import UserDocs.Name

  alias UserDocs.Web.Annotation
  alias UserDocs.Web.Element

  def execute(
    %Annotation{ annotation_type: %{ name:  name } } = annotation,
    %Element{} = element
    ) do
    ""
    |> maybe_field(annotation, :label, ": ")
    |> field(name, " ")
    |> maybe_field(element, :name, "")
  end

  def execute(_, _) do
    ""
  end
end
