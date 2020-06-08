defmodule UserDocsWeb.AnnotationTypeLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Web
  alias UserDocs.Web.AnnotationType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :annotation_types, list_annotation_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Annotation type")
    |> assign(:annotation_type, Web.get_annotation_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Annotation type")
    |> assign(:annotation_type, %AnnotationType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Annotation types")
    |> assign(:annotation_type, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    annotation_type = Web.get_annotation_type!(id)
    {:ok, _} = Web.delete_annotation_type(annotation_type)

    {:noreply, assign(socket, :annotation_types, list_annotation_types())}
  end

  defp list_annotation_types do
    Web.list_annotation_types()
  end
end
