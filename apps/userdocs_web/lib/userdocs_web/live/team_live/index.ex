defmodule UserDocsWeb.TeamLive.Index do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users
  alias UserDocs.Users.Team
  alias UserDocs.Helpers
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root
  alias UserDocsWeb.ComposableBreadCrumb

  @types [
    UserDocs.Users.Team,
    UserDocs.Users.User
  ]

  @impl true
  def mount(_params, session, socket) do
    opts = Defaults.opts(socket, @types)
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize(opts)
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in, state_opts: opts }} = socket) do
    socket
    |> assign(:modal_action, :show)
    |> load_teams()
    |> Users.load_users(opts)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(params, _url, %{ assigns: %{ auth_state: :not_logged_in }} = socket) do
    IO.puts("handle_params")
    {:noreply, socket}
  end
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    team = Users.get_team!(id, %{ preloads: [ users: true, projects: true, team_users: true ] })
    socket
    |> assign(:page_title, "Edit Team")
    |> assign(:team, team)
    |> assign(:projects_select_options, Helpers.select_list(team.projects, :name, false))
    |> prepare_teams()
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Team")
    |> assign(:team, %Team{ users: [], projects: [] })
    |> assign(:projects_select_options, [])
    |> prepare_teams()
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Teams")
    |> assign(:team, nil)
    |> prepare_teams()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Users.get_team!(id)
    {:ok, _} = Users.delete_team(team)

    { :noreply, socket }
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  def prepare_teams(socket) do
    socket
    |> assign(:teams, Users.list_teams(socket, socket.assigns.state_opts))
  end

  defp load_teams(socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filters, %{ user_id: socket.assigns.current_user.id})
    socket
    |> Users.load_teams(opts)
  end

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)
end
