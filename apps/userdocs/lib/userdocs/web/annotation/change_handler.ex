defmodule UserDocs.Web.Annotation.ChangeHandler do

  require Logger

  alias UserDocs.Web
  alias UserDocs.Automation
  alias UserDocs.Documents

  alias UserDocs.Automation.Step

  alias UserDocs.Web.Annotation.AutomaticName
  """
  def execute(%{annotation_type_id: annotation_type_id}, state) do
    Logger.debug("Handling a change to annotation type: {annotation_type_id}")

    new_annotation_type =
      state.data.annotation_types
      |> Enum.filter(fn(a) -> a.id == annotation_type_id end)
      |> Enum.at(0)

    existing_annotation = Map.get(
      state.changeset.changes, :annotation,
      state.step.annotation)

    updated_annotation =
      existing_annotation
      |> Map.put(:annotation_type, new_annotation_type)
      |> Map.put(:annotation_type_id, annotation_type_id)

    name =
      AutomaticName.execute(
        updated_annotation,
        state.current_object.element
      )

    current_annotation =
      state.current_object.annotation
      |> Map.put(:name, name)

    %{}
    |> Map.put(:annotation, current_annotation)
  end
  def execute(%{label: label} = annotation, state) do
    Logger.debug("Handling a change to annotation label: {label}")

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
  """
  def execute(%{content_id: content_id} = annotation, state) do
    Logger.debug("Handling a change to annotation content id: #{content_id}")
    content = Documents.get_content!(
      content_id, %{ content_version: true }, %{}, state.data.content)

    { :ok, new_annotation } =
      Web.update_annotation_content_id(
        state.current_object.annotation,
        state.current_object.annotation
        |> Map.put(:content_id, content_id)
      )

    new_annotation =
      new_annotation
      |> Map.put(:content, content)

    %{
      annotation: new_annotation
    }
  end
  def execute(_annotation, state) do
    Logger.debug("No changes we need to respond to on the annotation form")
    %{
      annotation: state.current_object.annotation
    }
  end

end
