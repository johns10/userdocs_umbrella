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
  end

  def apply(socket, session, types) do
    socket
    |> authorize(session)
    |> initialize(Defaults.opts(socket, types))
    |> assign_state_opts(types)
  end

  def authorize(socket, session) do
    socket
    |> validate_logged_in(session)
    |> put_app_name(session)
    |> app_assigns()
  end

  def initialize(socket, opts)
  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket, opts) do
    socket
    |> StateHandlers.initialize(opts)
    |> assign(:form_data, %{ action: :show })
    |> subscribe()
    |> assign(:state_opts, opts)
  end
  def initialize(socket, _), do: socket

  def assign_state_opts(socket, types) do
    socket
    |> assign(:state_opts, Defaults.opts(socket, types))
  end

  def subscribe(socket) do
    UserDocsWeb.Endpoint.subscribe(Defaults.channel(socket))
    socket
  end

  def validate_logged_in(socket, session) do
    try do
      case maybe_assign_current_user(socket, session) do
        %{ assigns: %{ current_user: nil }} ->
          IO.puts("nil user")
          socket
          |> assign(:auth_state, :not_logged_in)
          |> assign(:changeset, Users.change_user(%User{}))
        %{ assigns: %{ current_user: current_user }} ->
          IO.puts("a user")
          socket
          |> maybe_assign_current_user(session)
          |> prepare_user()
          |> assign_current()
          |> assign(:auth_state, :logged_in)
          |> (assign(:changeset, Users.change_user(current_user)))
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

  def prepare_user(%{ assigns: %{ current_user: current_user } } = socket) do
    current_user = Users.get_user_and_configs!(current_user.id)

    current_user =
      current_user
      |> Map.put(:selected_team, Users.try_get_team!(current_user.selected_team_id))
      |> Map.put(:selected_project, Projects.try_get_project!(current_user.selected_project_id))
      |> Map.put(:selected_version, Projects.try_get_version!(current_user.selected_version_id))

    assign(socket, :current_user, current_user)
  end

  def assign_current(%{ assigns: %{ current_user: current_user } } = socket) do
    { default_team, current_team } = current_team(current_user)
    { default_project, current_project } = current_project(current_user, default_team)
    { default_version, current_version } = current_version(current_user, default_project)

    current_user = assign_defaults(current_user, default_team, default_project, default_version)

    socket
    |> assign(:current_user, current_user)
    |> assign(:current_team, current_team)
    |> assign(:current_project, current_project)
    |> assign(:current_version, current_version)
  end

  def current_team(current_user) do
    default_team = Users.user_default_team(current_user)
    {
      default_team,
      current_user.selected_team
      || default_team
      || %Team{}
    }
  end

  def current_project(current_user, default_team) do
    default_project = Users.team_default_project(default_team)

    {
      default_project,
      current_user.selected_project
      || default_project
      || %Project{}
    }
  end

  def current_version(current_user, default_project) do
    default_version = Projects.project_default_version(default_project)
    {
      default_version,
      current_user.selected_version
      || default_version
      || %Version{}
    }
  end

  def assign_defaults(user, %Team{} = team, %Project{} = project, %Version{} = version) do
    Map.put(user, :default_team,
      Map.put(team, :default_project,
        Map.put(project, :default_version, version)
      )
    )
  end
  def assign_defaults(user, %Team{} = team, %Project{} = project, nil) do
    Map.put(user, :default_team,
      Map.put(team, :default_project,
        Map.put(project, :default_version, nil)
      )
    )
  end
  def assign_defaults(user, %Team{} = team, nil, nil) do
    Map.put(user, :default_team,
      Map.put(team, :default_project, nil)
    )
  end
  def assign_defaults(user, nil, nil, nil) do
    Map.put(user, :default_team, nil)
  end

  def put_app_name(socket, %{ "app_name" => app_name }) do
    uri =
      if Mix.env() in [:dev, :test] do
        URI.parse("https://dev.user-docs.com:4002")
      else
        URI.parse("https://app.user-docs.com")
      end
    socket
    |> assign(:app_name, app_name)
    |> assign(:uri, uri)
  end

  def app_assigns(%{ assigns: %{ app_name: "electron" } } = socket), do: socket
  def app_assigns(%{ assigns: %{ app_name: "web" } } = socket), do: socket

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
  def handle_event("new-content", params, socket) do
    IO.puts("Root making new Content")
    { :noreply, ModalMenus.new_content(socket, params) }
  end
  def handle_event("edit-content", params, socket) do
    IO.puts("Root handling Content")
    { :noreply, ModalMenus.edit_content(socket, params) }
  end
  def handle_event("edit-user", params, socket) do
    IO.puts("Root opening user form")
    { :noreply, ModalMenus.edit_user(socket, params) }
  end
  def handle_event("select-version", %{"version-id" => version_id, "project-id" => project_id, "team-id" => team_id } = _payload, socket) do
    IO.puts("Changing current version to #{version_id}")
    opts = Map.get(socket.assigns, :state_opts, state_opts())

    changes = %{
      selected_team_id: String.to_integer(team_id),
      selected_project_id: String.to_integer(project_id),
      selected_version_id: String.to_integer(version_id)
    }

    { :ok, user } =
      Users.update_user_selections(socket.assigns.current_user, changes)

    send(self(), { :broadcast, "update", user })

    {
      :noreply,
      socket
      |> prepare_user()
      |> assign_current()
    }

  end
  def handle_event(name, _payload, _socket) do
    raise(FunctionClauseError, message: "Event #{inspect(name)} not implemented by Root")
  end

  def handle_info(%{topic: topic, event: event, payload: payload}, socket) do
    schema = case payload do
      %{ objects: [ object | _ ]} -> object.__meta__.schema
      object -> object.__meta__.schema
    end
    Logger.debug("Root handling info on topic #{topic}, event #{event}, view: #{socket.view}, type: #{schema}")


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

  def handle_info({ :execute_step, %{ step_id: step_id } = payload }, socket) do
    IO.inspect("root got execute_step")
    {
      :noreply,
      socket
      |> UserDocsWeb.AutomationManagerLive.execute_step(payload)
    }
  end
  def handle_info({ :execute_process, %{ process_id: process_id } = payload }, socket) do
    IO.inspect("root got execute_step")
    {
      :noreply,
      socket
      |> UserDocsWeb.AutomationManagerLive.execute_process_instance(payload, 0)
    }
  end
  def handle_info({ :queue_process_instance, payload }, socket) do
    IO.inspect("root got add_process")
    {
      :noreply,
      socket
      |> UserDocsWeb.AutomationManagerLive.queue_process(payload)
    }
  end
  def handle_info(name, _socket) do
    raise(FunctionClauseError, message: "Subscription #{inspect(name)} not implemented by Root")
  end
end
