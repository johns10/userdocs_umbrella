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
    |> PhoenixLiveSession.maybe_subscribe(session)
    |> live_session_status()
    |> assign(:browser_opened, Map.get(session, "browser_opened", false))
    |> assign(:user_opened_browser, Map.get(session, "user_opened_browser", false))
    |> assign(:navigation_drawer_closed, Map.get(session, "navigation_drawer_closed", true))
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
    case Defaults.channel(socket) do
      channel when is_binary(channel) ->
        UserDocsWeb.Endpoint.subscribe(channel)
        socket
      _ -> socket
    end
  end

  def validate_logged_in(socket, session) do
    case maybe_assign_current_user(socket, session) do
      %{ assigns: %{ current_user: nil }} ->
        Logger.debug("No user found in socket")
        socket
        |> assign(:auth_state, :not_logged_in)
        |> assign(:changeset, Users.change_user(%User{}))
        |> push_redirect(to: UserDocsWeb.Router.Helpers.pow_session_path(socket, :new))
      %{ assigns: %{ current_user: current_user }} ->
        Logger.debug("User #{current_user.id} found in socket")
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
      || current_user.teams |> Enum.at(0)
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
      || nil
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
    changes = %{
      selected_team_id: String.to_integer(team_id),
      selected_project_id: String.to_integer(project_id),
      selected_version_id: String.to_integer(version_id)
    }

    { :ok, user } =
      Users.update_user_selections(socket.assigns.current_user, changes)

    send(self(), { :broadcast, "update", user })

    version = Projects.get_version!(version_id, %{ strategy: true })

    configuration = [
      id: "configuration",
      image_path: socket.assigns.current_user.image_path,
      strategy: version.strategy.name |> to_string,
      user_data_dir_path: socket.assigns.current_user.user_data_dir_path
    ]
    send_update(UserDocsWeb.Configuration, configuration)

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
      nil -> raise(RuntimeError, "Types not populated in calling subscribed view #{socket.view}")
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
  def handle_info({ :update_session, params }, socket) do
    IO.puts("Attempting to update session")
    IO.inspect(params)
    socket =
      Enum.reduce(params, socket,
        fn({ k, v }, inner_socket) ->
          PhoenixLiveSession.put_session(inner_socket, k, v)
        end
      )
    { :noreply, socket }
  end
  def handle_info({ :live_session_updated, params }, socket) do
  IO.puts("Handling info for a live session update")
  {
    :noreply,
    socket
    |> maybe_update_user_opened_browser(params["user_opened_browser"])
    |> maybe_update_browser_opened(params["browser_opened"])
    |> maybe_update_navigation_drawer_closed(params["navigation_drawer_closed"])
  }
  end
  def handle_info(name, _socket) do
    raise(FunctionClauseError, message: "Subscription #{inspect(name)} not implemented by Root")
  end

  defp maybe_update_user_opened_browser(socket, nil), do: socket
  defp maybe_update_user_opened_browser(socket, user_opened_browser) do
    assign(socket, :user_opened_browser, user_opened_browser)
  end

  defp maybe_update_browser_opened(socket, nil), do: socket
  defp maybe_update_browser_opened(socket, browser_opened) do
    assign(socket, :browser_opened, browser_opened)
  end

  defp maybe_update_navigation_drawer_closed(socket, nil), do: socket
  defp maybe_update_navigation_drawer_closed(socket, navigation_drawer_closed) do
    assign(socket, :navigation_drawer_closed, navigation_drawer_closed)
  end

  def live_session_status(socket) do
    socket
    |> Map.get(:assigns)
    |> Map.get(:__live_session_id__, "Failed to fetch session status")
    |> IO.inspect()

    socket
  end
end
