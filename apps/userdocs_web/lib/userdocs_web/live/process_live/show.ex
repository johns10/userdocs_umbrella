defmodule UserDocsWeb.ProcessesLive.Show do
  use UserDocsWeb, :live_view

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
     |> assign(:process, Automation.get_process!(id))}
  end

  defp page_title(:show), do: "Show Process"
  defp page_title(:edit), do: "Edit Process"
end
