defmodule UserDocsWeb.AnnotationLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Web

  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    changeset = Web.change_annotation(annotation)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"annotation" => annotation_params}, socket) do
    changeset =
      socket.assigns.annotation
      |> Web.change_annotation(annotation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
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
         |> push_redirect(to: socket.assigns.return_to)}

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
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
