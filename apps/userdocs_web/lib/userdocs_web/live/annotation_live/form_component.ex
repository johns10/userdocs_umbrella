defmodule UserDocsWeb.AnnotationLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Web

  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.Layout

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:enabled_fields, [])

    {:ok, socket}
  end

  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    changeset = Web.change_annotation(annotation)
    maybe_parent_id = DomainHelpers.maybe_parent_id(assigns, :page_id)
    enabled_fields =
      LiveHelpers.enabled_fields(assigns.select_lists.available_annotation_types,
        changeset.data.annotation_type_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:enabled_fields, enabled_fields)
     |> assign(:read_only, LiveHelpers.read_only?(assigns))
     |> assign(:changeset, changeset)
     |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
     |> assign(:maybe_parent_id, maybe_parent_id)}
  end

  @impl true
  def handle_event("validate", %{"annotation" => annotation_params}, socket) do
    enabled_fields =
      LiveHelpers.enabled_fields(socket.assigns.select_lists.available_annotation_types,
      annotation_params["annotation_type_id"])

    changeset =
      socket.assigns.annotation
      |> Web.change_annotation(annotation_params)
      |> Map.put(:action, :validate)

      socket =
        socket
        |> assign(:changeset, changeset)
        |> assign(:enabled_fields, enabled_fields)

    {:noreply, socket}
  end

  def handle_event("save", %{"annotation" => annotation_params}, socket) do
    save_annotation(socket, socket.assigns.action, annotation_params)
  end

  defp save_annotation(socket, :edit, annotation_params) do
    case Web.update_annotation(socket.assigns.annotation, annotation_params) do
      {:ok, _annotation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation updated successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_annotation(socket, :new, annotation_params) do
    case Web.create_annotation(annotation_params) do
      {:ok, _annotation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation created successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
