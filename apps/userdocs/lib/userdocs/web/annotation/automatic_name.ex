defmodule UserDocs.Web.Annotation.AutomaticName do

  require Logger

  import UserDocs.Name

  def execute(%{ annotation_type: %{ name:  name } } = annotation, element) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(annotation, :label, ": ")
    |> field(name, " ")
    |> maybe_field(element, :name, "")
  end
end
