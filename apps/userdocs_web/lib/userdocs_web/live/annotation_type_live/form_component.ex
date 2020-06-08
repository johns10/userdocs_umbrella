defmodule UserDocsWeb.AnnotationTypeLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Web

  @impl true
  def update(%{annotation_type: annotation_type} = assigns, socket) do
    changeset = Web.change_annotation_type(annotation_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"annotation_type" => annotation_type_params}, socket) do
    changeset =
      socket.assigns.annotation_type
      |> Web.change_annotation_type(annotation_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"annotation_type" => annotation_type_params}, socket) do
    save_annotation_type(socket, socket.assigns.action, annotation_type_params)
  end

  defp save_annotation_type(socket, :edit, annotation_type_params) do
    case Web.update_annotation_type(socket.assigns.annotation_type, annotation_type_params) do
      {:ok, _annotation_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation type updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_annotation_type(socket, :new, annotation_type_params) do
    case Web.create_annotation_type(annotation_type_params) do
      {:ok, _annotation_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation type created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
