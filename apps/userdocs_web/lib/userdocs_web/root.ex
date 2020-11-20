defmodule UserDocsWeb.Root do
  use Phoenix.LiveView
  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocs.Projects
  alias UserDocs.Projects.Select

  alias StateHandlers

  @state_opts [ data_type: :list, strategy: :by_type, loader: &Phoenix.LiveView.assign/3 ]

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
    |> team_users()
    |> teams()
    |> Select.assign_default_team_id(&assign/3)
    |> projects()
    |> versions()
    |> socket_inspector
  end
  def initialize(socket), do: socket

  def team_users(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    team_users = Users.list_team_users(%{}, %{ user_id: user_id })
    assign(socket, :team_users, team_users)
  end

  def teams(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    opts = Keyword.put(@state_opts, :type, :teams)
    teams = Users.list_teams(%{}, %{ user_id: user_id })
    StateHandlers.load(socket, teams, opts)
  end

  def projects(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    opts = Keyword.put(@state_opts, :type, :projects)
    projects = Projects.list_projects(%{}, %{ user_id: user_id })
    StateHandlers.load(socket, projects, opts)
  end

  def versions(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    opts = Keyword.put(@state_opts, :type, :versions)
    versions = Projects.list_versions(%{}, %{ user_id: user_id })
    StateHandlers.load(socket, versions, opts)
  end

  def socket_inspector(socket) do
    IO.inspect(socket.assigns.current_team_id)
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

  def handle_event("select_version", payload, socket) do

  end
  def handle_event(name, _payload, _socket) do
    raise(FunctionClauseError, "Event #{name} not implemented by Root")
  end

  def handle_info(name, _socket) do
    raise(FunctionClauseError, "Subscription #{name} not implemented by Root")
  end
end
