defmodule UserDocsWeb.TeamUserLive.Show do
  use UserDocsWeb, :live_view

  alias UserDocs.Users

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:team_user, Users.get_team_user!(id))}
  end

  defp page_title(:show), do: "Show Team user"
  defp page_title(:edit), do: "Edit Team user"
end
