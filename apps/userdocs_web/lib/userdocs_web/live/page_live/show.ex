defmodule UserDocsWeb.PageLive.Show do
  use UserDocsWeb, :live_view

  alias UserDocs.Web
  alias UserDocs.Automation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:page, Web.get_page!(id))}
  end

  defp page_title(:show), do: "Show Page"
  defp page_title(:edit), do: "Edit Page"
end
