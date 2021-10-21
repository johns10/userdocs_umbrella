defmodule UserDocsWeb.AnnotationLive.FormComponentNew do
  use UserDocsWeb, :live_slime_component

  require Logger

  alias UserDocsWeb.Layout

  alias UserDocs.Annotations
  alias UserDocs.Web

  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    changeset = Annotations.change_annotation(annotation)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"annotation" => annotation_params}, socket) do
    changeset =
      socket.assigns.annotation
      |> Annotations.change_annotation(annotation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"annotation" => annotation_params}, socket) do
    save_annotation(socket, socket.assigns.action, annotation_params)
  end

  defp save_annotation(socket, :edit, annotation_params) do
    case Annotations.update_annotation(socket.assigns.annotation, annotation_params) do
      {:ok, _annotation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation updated successfully")
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_annotation(socket, :new, annotation_params) do
    case Annotations.create_annotation(annotation_params) do
      {:ok, _annotation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation created successfully")
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def field_enabled?(changeset, name, annotation_types) do
    case Ecto.Changeset.get_field(changeset, :annotation_type_id) do
      nil -> false
      annotation_type_id ->
        annotation = Enum.filter(annotation_types, fn(at) -> at.id == annotation_type_id end) |> Enum.at(0)
        enabled_fields = annotation.args |> Enum.map(fn(a) -> String.to_atom(a) end)
        name in enabled_fields
    end
  end
end
