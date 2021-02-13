defmodule UserDocsWeb.TeamLive.Show do
  use UserDocsWeb, :live_view

  alias UserDocs.Users

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:teams, Users.list_teams())
      |> assign(:users, Users.list_users())

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:team, Users.get_team!(id))}
  end

  defp page_title(:show), do: "Show Team"
  defp page_title(:edit), do: "Edit Team"
end
