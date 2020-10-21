defmodule UserDocs.Automation.Step.ChangeHandler do

  require Logger

  alias UserDocsWeb.LiveHelpers

  alias UserDocs.Web
  alias UserDocs.Automation

  alias UserDocs.Automation.Step
  alias UserDocs.Automation.Step.Name

  alias UserDocs.Web.Annotation

  def execute(%{order: order}, state) do
    Logger.debug("Handling a change to order: #{order}")
    %{
      current_object:
        state.current_object
        |> Map.put(:order, order)
        |> (&(Map.put(&1, :name, Name.execute(&1)))).(),
    }
  end
  def execute(%{step_type_id: step_type_id}, state) do
    Logger.debug("Handling a change to step type id: #{step_type_id}")
    %{
      current_object:
        state.current_object
        |> Map.put(:step_type, Automation.get_step_type!(state.data, step_type_id))
        |> Map.put(:step_type_id, step_type_id)
        |> (&(Map.put(&1, :name, Name.execute(&1)))).(),

      enabled_step_fields:
        LiveHelpers.enabled_fields(state.data.step_types, step_type_id)
    }
  end
  def execute(%{page_reference: page_reference}, state) do
    Logger.debug("Handling a change to url mode: #{page_reference}")
    %{
      current_object:
        Map.put(state.current_object, :page_reference, page_reference)
    }
  end
  def execute(%{page_id: page_id}, state) do
    Logger.debug("Handling a change to page id: #{page_id}")
    %{
      current_object:
        state.current_object
        |> Map.put(:page_id, page_id)
        |> Map.put(:page, Web.get_page!(state.data, page_id))
        |> (&(Map.put(&1, :name, Name.execute(&1)))).(),
    }
  end
  def execute(%{annotation_id: annotation_id}, state) do
    Logger.debug("Handling a change to annotation id: #{annotation_id}")
    Automation.update_step_annotation_id(
      state.step,
      new_object =
        state.current_object
        |> Map.put(:annotation_id, annotation_id)
        |> Map.put(:annotation, Web.get_annotation!(state.data, annotation_id))
    )

    %{
      current_object: new_object,

      changeset:
        state.changeset.data
        |> Map.put(:annotation_id, annotation_id)
        |> Map.put(:annotation, Web.get_annotation!(state.data, annotation_id))
        |> (&(Map.put(state.changeset, :data, &1))).(),

      step:
        state.step
        |> Map.put(:annotation_id, annotation_id)
        |> Map.put(:annotation, Web.get_annotation!(state.data, annotation_id))
        |> (&(Map.put(&1, :name, Name.execute(&1)))).()

    }
  end
  def execute(%{element_id: element_id}, state) do
    Logger.debug("Handling a change to element id: #{element_id}")
    element = Web.get_element!(state.data, element_id)

    Automation.update_step_element_id(
      state.step,
      new_object =
        state.current_object
        |> Map.put(:element_id, element_id)
        |> Map.put(:element, element)
    )

    %{
      current_object: new_object,

      changeset:
        state.changeset.data
        |> Map.put(:element_id, element_id)
        |> Map.put(:element, element)
        |> (&(Map.put(state.changeset, :data, &1))).(),

      step:
        state.step
        |> Map.put(:element_id, element_id)
        |> Map.put(:element, Web.get_element!(state.data, element_id))
        |> (&(Map.put(&1, :name, Name.execute(&1)))).()

    }
  end
  def execute(%{element_id: element_id}, socket) do
    Logger.debug("Handling a change to element id: #{element_id}")
    %{}
  end
  def execute(%{annotation: %{ changes: %{annotation_type_id: annotation_type_id}} = annotation}, state) do
    Logger.debug("Handling a change to content id in the annotation type: #{annotation_type_id}")
    changes = Annotation.ChangeHandler.execute(annotation.changes, state)
    %{
      enabled_annotation_fields:
        LiveHelpers.enabled_fields(
          state.data.annotation_types,
          annotation_type_id),

      current_object:
        state.current_object
        |> Map.put(:annotation, changes.annotation)
        |> (&(Map.put(&1, :name, Name.execute(&1)))).(),
    }
  end
  def execute(%{annotation: annotation}, state) do
    Logger.debug("Handling a change to the nested annotation:")
    changes = Annotation.ChangeHandler.execute(annotation.changes, state)
    %{
      current_object:
        Map.put(state.current_object, :annotation, changes.annotation)
    }
  end
  def execute(%{annotation: %{changes: %{content_id: content_id}}}, socket) do
    # In this function we'll fetch the versions, and the content versions for the selected
    # content id, and pick the current content version as the first item in content_versions
    Logger.debug("Handling a change to content id in the annotation: #{content_id}")
    %{}
  end
  def execute(object, socket) do
    IO.puts("No changes we need to respond to on the step form")
    %{}
  end
end
