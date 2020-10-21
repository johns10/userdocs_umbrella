defmodule UserDocs.Web.Annotation.ChangeHandler do

  require Logger

  alias UserDocsWeb.LiveHelpers

  alias UserDocs.Web
  alias UserDocs.Automation

  alias UserDocs.Automation.Step

  alias UserDocs.Web.Annotation.AutomaticName

  def execute(%{annotation_type_id: annotation_type_id}, state) do
    IO.puts("Handling a change to annotation type: #{annotation_type_id}")

    new_annotation_type =
      state.data.annotation_types
      |> Enum.filter(fn(a) -> a.id == annotation_type_id end)
      |> Enum.at(0)

    current_annotation =
      state.current_object.annotation
      |> Map.put(:annotation_type, new_annotation_type)
      |> Map.put(:annotation_type_id, annotation_type_id)

    name =
      AutomaticName.execute(
        current_annotation,
        state.current_object.element
      )

    current_annotation =
      current_annotation
      |> Map.put(:name, name)

    %{}
    |> Map.put(:annotation, current_annotation)
  end
  def execute(%{label: label} = annotation, state) do
    IO.puts("Handling a change to annotation label: #{label}")

    name =
      AutomaticName.execute(
        annotation,
        state.current_object.element
      )

    current_annotation =
      annotation
      |> Map.put(:name, name)

    %{}
    |> Map.put(:annotation, current_annotation)
  end
  def execute(_annotation, state) do
    IO.puts("No changes we need to respond to on the annotation form")
    %{
      annotation: state.current_object.annotation
    }
  end

end
