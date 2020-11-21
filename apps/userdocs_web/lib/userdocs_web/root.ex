defmodule UserDocsWeb.Root do
  use Phoenix.LiveView
  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocs.Users.Team
  alias UserDocs.Projects
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version
  alias UserDocs.Projects.Select

  alias StateHandlers
  alias UserDocsWeb.Defaults

  def render(assigns) do
    ~L"""
    """
  end

  def authorize(socket, session) do
    socket
    |> validate_logged_in(session)
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    socket
    |> users()
    |> team_users()
    |> teams()
    |> projects()
    |> versions()
    |> Select.assign_default_team_id(&assign/3)
    |> Select.assign_default_project_id(&assign/3, Defaults.state_opts())
    |> Select.assign_default_version_id(&assign/3, Defaults.state_opts())
  end
  def initialize(socket), do: socket

  def users(%{ assigns: %{ current_user: current_user }} = socket) do
    assign(socket, :users, [ current_user ])
  end

  @spec team_users(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  def team_users(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    team_users = Users.list_team_users(%{}, %{ user_id: user_id })
    assign(socket, :team_users, team_users)
  end

  def teams(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    teams = Users.list_teams(%{}, %{ user_id: user_id })
    StateHandlers.load(socket, teams, Team, Defaults.state_opts(:teams))
  end

  def projects(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    projects = Projects.list_projects(%{}, %{ user_id: user_id })
    StateHandlers.load(socket, projects, Project, Defaults.state_opts(:projects))
  end

  def versions(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    versions = Projects.list_versions(%{}, %{ user_id: user_id })
    StateHandlers.load(socket, versions, Version, Defaults.state_opts(:versions))
  end

  def socket_inspector(socket) do
    IO.inspect(socket.assigns)
    socket
  end

  def validate_logged_in(socket, session) do
    try do
      case maybe_assign_current_user(socket, session) do
        %{ assigns: %{ current_user: nil }} ->
          socket
          |> assign(:auth_state, :not_logged_in)
          |> assign(:changeset, Users.change_user(%User{}))
        %{ assigns: %{ current_user: _ }} ->
          socket
          |> maybe_assign_current_user(session)
          |> assign(:auth_state, :logged_in)
          |> (&(assign(&1, :changeset, Users.change_user(&1.assigns.current_user)))).()
        error ->
          Logger.error(error)
          socket
      end
    rescue
      FunctionClauseError ->
        socket
        |> assign(:auth_state, :not_logged_in)
        |> assign(:changeset, Users.change_user(%User{}))
    end
  end



  def handle_event("select_version", %{"select-version" => version_id_param} = _payload, socket) do
    opts = Defaults.state_opts()
    with  version_id <- String.to_integer(version_id_param),
      version <- UserDocs.Projects.get_version!(version_id, socket, opts),
      project <- UserDocs.Projects.get_project!(version.project_id, socket, opts),
      team <- UserDocs.Users.get_team!(project.team_id, socket, opts)
    do
      {
        :noreply,
        socket
        |> assign(:current_team_id, team.id)
        |> assign(:current_project_id, project.id)
        |> assign(:current_version_id, version.id)
      }
    end
  end
  def handle_event(name, _payload, _socket) do
    raise(FunctionClauseError, "Event #{name} not implemented by Root")
  end

  def handle_info(name, _socket) do
    raise(FunctionClauseError, "Subscription #{name} not implemented by Root")
  end
end
