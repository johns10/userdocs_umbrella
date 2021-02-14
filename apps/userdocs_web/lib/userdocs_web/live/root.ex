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
    |> put_app_name(session)
  end

  def initialize(socket, opts \\ state_opts())
  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket, opts) do
    types_to_initialize = [ User, TeamUser, Team, Project, Version ] ++ Keyword.get(opts, :types, [])

    initialization_opts =
      opts
      |> Keyword.put(:types, types_to_initialize)

    socket
    |> StateHandlers.initialize(initialization_opts)
    |> assign(:form_data, %{ action: :show })
    |> users(opts)
    |> team_users(opts)
    |> teams(opts)
    |> projects(opts)
    |> versions(opts)
    |> Select.assign_default_team_id(&assign/3)
    |> Select.assign_default_project_id(&assign/3, opts)
    |> Select.assign_default_version_id(&assign/3, opts)
    |> subscribe()
  end
  def initialize(socket, _), do: socket

  def subscribe(socket) do
    UserDocsWeb.Endpoint.subscribe(Defaults.channel(socket))
    socket
  end


  def users(%{ assigns: %{ current_user: current_user }} = socket, opts \\ state_opts()) do
    socket
    |> StateHandlers.load([ current_user ], opts)
  end

  def team_users(%{ assigns: %{ current_user: %{ id: user_id }}} = socket, opts \\ state_opts()) do
    opts = opts |> Keyword.put(:filters, %{ user_id: user_id })
    Users.load_team_users(socket, opts)
  end

  def teams(%{ assigns: %{ current_user: %{ id: user_id }}} = socket, opts \\ state_opts()) do
    opts = opts |> Keyword.put(:filters, %{ user_id: user_id })
    Users.load_teams(socket, opts)
  end

  def projects(%{ assigns: %{ current_user: %{ id: user_id }}} = socket, opts \\ state_opts()) do
    opts = opts |> Keyword.put(:filters, %{ user_id: user_id })
    Projects.load_projects(socket, opts)
  end

  def versions(%{ assigns: %{ current_user: %{ id: user_id }}} = socket, opts \\ state_opts()) do
    opts = opts |> Keyword.put(:filters, %{ user_id: user_id })
    Projects.load_versions(socket, opts)
  end

  def validate_logged_in(socket, session) do
    try do
      case maybe_assign_current_user(socket, session) do
        %{ assigns: %{ current_user: nil }} ->
          IO.puts("nil user")
          socket
          |> assign(:auth_state, :not_logged_in)
          |> assign(:changeset, Users.change_user(%User{}))
        %{ assigns: %{ current_user: _ }} ->
          IO.puts("a user")
          socket
          |> maybe_assign_current_user(session)
          |> assign(:auth_state, :logged_in)
          |> (&(assign(&1, :changeset, Users.change_user(&1.assigns.current_user)))).()
        error ->
          IO.puts("Error")
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

  def put_app_name(socket, %{ "app_name" => app_name }) do
    uri =
      if Mix.env() in [:dev, :test] do
        URI.parse("https://user-docs.com:4002")
      else
        URI.parse("https://app.user-docs.com")
      end
    socket
    |> assign(:app_name, app_name)
    |> assign(:uri, uri)
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
  def handle_event("new-process", params, socket) do
    ModalMenus.new_process(socket, params)
  end
  def handle_event("new-step", params, socket) do
    ModalMenus.new_step(socket, params)
  end
  def handle_event("delete-docubit", params, socket) do
    UserDocsWeb.DocubitLive.EventHandlers.handle_event("delete", params, socket)
  end
  def handle_event("edit-docubit", params, socket) do
    ModalMenus.edit_docubit(socket, params)
  end
  def handle_event("edit-content", params, socket) do
    IO.puts("Root handling Content")
    { :noreply, ModalMenus.edit_content(socket, params) }
  end
  def handle_event("select-version", %{"select-version" => version_id_param} = _payload, socket) do
    opts = Map.get(socket.assigns, :state_opts, state_opts())
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
    raise(FunctionClauseError, message: "Event #{inspect(name)} not implemented by Root")
  end

  def handle_info(%{topic: topic, event: event, payload: payload}, socket) do
    Logger.debug("Root handling info on topic #{topic}, event #{event}, view: #{socket.view}")
    schema = case payload do
      %{ objects: [ object | _ ]} -> object.__meta__.schema
      object -> object.__meta__.schema
    end

    case Keyword.get(socket.assigns.state_opts, :types) do
      nil -> raise(RuntimeError, "Types not populated in calling subscribed view")
      _ -> ""
    end

    socket =
      case schema in socket.assigns.state_opts[:types] do
        true -> UserDocs.Subscription.handle_event(socket, event, payload, socket.assigns.state_opts)
        false -> socket
      end
    { :noreply, socket }
  end
  def handle_info({:update_form_data, form_data}, socket) do
    { :noreply, assign(socket, :form_data, form_data )}
  end
  def handle_info({:broadcast, action, data}, socket) do
    Logger.debug("Handling #{data.__meta__.schema} Broadcast")
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:action, action)

    StateHandlers.broadcast(socket, data, opts)
    { :noreply, socket }
  end
  def handle_info(:close_modal, socket), do: { :noreply, ModalMenus.close(socket) }
  def handle_info(name, _socket) do
    raise(FunctionClauseError, message: "Subscription #{inspect(name)} not implemented by Root")
  end
end
