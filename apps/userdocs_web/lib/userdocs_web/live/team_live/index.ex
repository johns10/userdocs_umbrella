defmodule UserDocsWeb.TeamLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Users
  alias UserDocs.Users.Team

  @impl true
  def mount(_params, _session, socket) do
    socket = 
      socket 
      |> assign(:teams, list_teams())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Team")
    |> assign(:users, list_users())
    |> assign(:team, Users.get_team!(id))
  end

  defp apply_action(socket, :new, _params) do
    team = 
      %Team{}
      |> Map.put(:users, [])

    socket
    |> assign(:page_title, "New Team")
    |> assign(:team, team)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Teams")
    |> assign(:team, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Users.get_team!(id)
    {:ok, _} = Users.delete_team(team)

    {:noreply, assign(socket, :teams, list_teams())}
  end

  defp list_teams do
    Users.list_teams()
  end

  defp list_users do
    Users.list_users()
  end
end
