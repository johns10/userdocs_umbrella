defmodule UserDocsWeb.AnnotationTypeLive.Show do
  use UserDocsWeb, :live_view

  alias UserDocs.Web

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:annotation_type, Web.get_annotation_type!(id))}
  end

  defp page_title(:show), do: "Show Annotation type"
  defp page_title(:edit), do: "Edit Annotation type"
end
