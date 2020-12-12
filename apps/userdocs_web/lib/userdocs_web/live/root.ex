defmodule UserDocsWeb.Root do
  use Phoenix.LiveView
  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocs.Users.TeamUser
  alias UserDocs.Users.Team
  alias UserDocs.Projects
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version
  alias UserDocs.Projects.Select

  alias StateHandlers
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.ModalMenus

  def render(assigns) do
    ~L"""
    """
  end

  def state_opts() do
    Defaults.state_opts()
    |> Keyword.put(:location, :data)
  end

  def authorize(socket, session) do
    socket
    |> validate_logged_in(session)
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts =
      state_opts()
      |> Keyword.put(:types, [ User, TeamUser, Team, Project, Version  ])

    socket
    |> StateHandlers.initialize(opts)
    |> assign(:modal_action, :show)
    |> users()
    |> team_users()
    |> teams()
    |> projects()
    |> versions()
    |> Select.assign_default_team_id(&assign/3)
    |> Select.assign_default_project_id(&assign/3, state_opts())
    |> Select.assign_default_version_id(&assign/3, state_opts())
    |> subscribe()
  end
  def initialize(socket), do: socket

  def subscribe(socket) do
    UserDocsWeb.Endpoint.subscribe(Defaults.channel(socket))
    socket
  end


  def users(%{ assigns: %{ current_user: current_user }} = socket) do
    data =
      socket.assigns
      |> Map.get(:data)
      |> Map.put(:users, [ current_user ])

    assign(socket, :data, data)
  end

  @spec team_users(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  def team_users(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    opts = state_opts() |> Keyword.put(:filters, %{ user_id: user_id })
    Users.load_team_users(socket, opts)
  end

  def teams(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    opts = state_opts() |> Keyword.put(:filters, %{ user_id: user_id })
    Users.load_teams(socket, opts)
  end

  def projects(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    opts = state_opts() |> Keyword.put(:filters, %{ user_id: user_id })
    Projects.load_projects(socket, opts)
  end

  def versions(%{ assigns: %{ current_user: %{ id: user_id }}} = socket) do
    opts = state_opts() |> Keyword.put(:filters, %{ user_id: user_id })
    Projects.load_versions(socket, opts)
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

  def handle_event("delete-document-version", p, s) do
    UserDocsWeb.DocumentVersionLive.EventHandlers.handle_event("delete", p, s)
  end
  def handle_event("new-document-version", params, socket) do
    ModalMenus.new_document_version(socket, Map.put(params, :channel, Defaults.channel(socket)))
  end
  def handle_event("edit-document-version", params, socket) do
    ModalMenus.edit_document_version(socket, Map.put(params, :channel, Defaults.channel(socket)))
  end
  def handle_event("edit-document", params, socket) do
    ModalMenus.edit_document(socket, params)
  end
  def handle_event("new-document", params, socket) do
    ModalMenus.new_document(socket, params)
  end
  def handle_event("delete-docubit" = name, params, socket) do
    UserDocsWeb.DocubitLive.EventHandlers.handle_event("delete", params, socket)
  end
  def handle_event("select_version", %{"select-version" => version_id_param} = _payload, socket) do
    opts = state_opts()
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
    raise(FunctionClauseError, "Event #{inspect(name)} not implemented by Root")
  end

  def handle_info(%{topic: topic, event: event, payload: payload}, socket) do
    #Logger.debug("Root handling info on topic #{topic}, event #{event}")
    {
      :noreply,
      UserDocs.Subscription.handle_event(socket, event, payload, state_opts())
    }
  end
  def handle_info(:close_modal, socket), do: { :noreply, ModalMenus.close(socket) }
  def handle_info(name, _socket) do
    raise(FunctionClauseError, "Subscription #{inspect(name)} not implemented by Root")
  end
end
