defmodule UserDocsWeb.TeamUserLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Users
  alias UserDocs.Users.TeamUser

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :team_users, list_team_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Team user")
    |> assign(:team_user, Users.get_team_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Team user")
    |> assign(:team_user, %TeamUser{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Team users")
    |> assign(:team_user, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team_user = Users.get_team_user!(id)
    {:ok, _} = Users.delete_team_user(team_user)

    {:noreply, assign(socket, :team_users, list_team_users())}
  end

  defp list_team_users do
    Users.list_team_users()
  end
end
