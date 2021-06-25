defmodule UserDocsWeb.StepLive.FormComponent.Helpers do
  alias UserDocs.Automation
  alias UserDocs.Web
  alias UserDocs.Web.Annotation

  def enabled_step_fields(socket, changeset) do
    UserDocsWeb.LiveHelpers.enabled_fields(
      Automation.list_step_types(socket, socket.assigns.state_opts),
      Ecto.Changeset.get_field(changeset, :step_type_id)
    )
  end

  def enabled_annotation_fields(socket, changeset) do
    annotation_type_id =
      changeset
      |> Ecto.Changeset.get_field(:annotation)
      |> case do
          nil -> nil
          %Annotation{} = annotation -> Map.get(annotation, :annotation_type_id)
        end

    UserDocsWeb.LiveHelpers.enabled_fields(
      Web.list_annotation_types(socket, socket.assigns.state_opts),
      annotation_type_id
    )
  end
end
