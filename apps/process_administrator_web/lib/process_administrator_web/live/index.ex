defmodule ProcessAdministratorWeb.IndexLive do
  @behaviour Gettext.Plural
  require Logger

  use ProcessAdministratorWeb, :live_view
  use ProcessAdministratorWeb.LiveViewPowHelper

  alias ProcessAdministratorWeb.Endpoint
  alias ProcessAdministratorWeb.DomainHelpers
  alias ProcessAdministratorWeb.ID
  alias ProcessAdministratorWeb.State
  alias ProcessAdministratorWeb.ProcessLive
  alias ProcessAdministratorWeb.StepLive
  alias ProcessAdministratorWeb.LiveHelpers
  alias ProcessAdministratorWeb.Layout

  alias ProcessAdministratorWeb.ProjectLive.Messages, as: ProjectMessage
  alias ProcessAdministratorWeb.VersionLive.Messages, as: VersionMessage
  alias ProcessAdministratorWeb.ProcessLive.Messages, as: ProcessMessage

  alias UserDocs.Automation.Step
  alias UserDocs.Web
  alias UserDocs.Web.Strategy
  alias UserDocs.Web.Element
  alias UserDocs.Web.Annotation
  alias UserDocs.Projects.Version
  alias UserDocs.Automation
  alias UserDocs.Projects.Select
  alias UserDocs.Projects.Version
  alias UserDocs.Projects.Project
  alias UserDocs.Documents
  alias UserDocs.Documents.Content
  alias UserDocs.Projects.Select

  alias ProcessAdministratorWeb.State

  @impl true
  def mount(_params, session, socket) do
    Endpoint.subscribe("version")
    Endpoint.subscribe("project")
    Endpoint.subscribe("page")
    Endpoint.subscribe("process")
    Endpoint.subscribe("step")
    Endpoint.subscribe("element")
    Endpoint.subscribe("annotation")
    Endpoint.subscribe("content")

    # Get Data from the Database
    Logger.debug("DB operations")
    socket =
      socket
      |> validate_logged_in(session)
      |> initialize()

    {:ok, socket}
  end

  def validate_logged_in(socket, session) do
    try do
      case maybe_assign_current_user(socket, session) do
        %{ assigns: %{ current_user: nil }} ->
          socket
          |> assign(:auth_state, :not_logged_in)
          |> assign(:changeset, UserDocs.Users.change_user(%UserDocs.Users.User{}))
        %{ assigns: %{ current_user: _ }} ->
          socket
          |> maybe_assign_current_user(session)
          |> assign(:auth_state, :logged_in)
          |> (&(assign(&1, :changeset, UserDocs.Users.change_user(&1.assigns.current_user)))).()
        error ->
          IO.inspect(error)
          socket
      end
    rescue
      FunctionClauseError ->
        socket
        |> assign(:auth_state, :not_logged_in)
        |> assign(:changeset, UserDocs.Users.change_user(%UserDocs.Users.User{}))
    end
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    socket
    |> assign(:modal_action, :show)
    |> assign(:transferred_strategy, %Strategy{})
    |> assign(:transferred_selector, "")
    |> (&(  assign(&1, :annotation_types, State.annotation_types())                                         )).()
    |> (&(  assign(&1, :strategies,       State.strategies())                                               )).()
    |> (&(  assign(&1, :language_codes,   State.language_codes())                                           )).()
    |> (&(  assign(&1, :step_types,       State.step_types())                                               )).()
    |> (&(  assign(&1, :teams,            State.teams(&1.assigns.current_user.id))                          )).()
    |> (&(  assign(&1, :team_users,       State.team_users(&1.assigns.current_user.id))                     )).()
    |> (&(  assign(&1, :projects,         State.projects(&1.assigns.current_user.id))                       )).()
    |> (&(  assign(&1, :versions,         State.versions(&1.assigns.current_user.default_team_id))          )).()
    |> (&(  assign(&1, :content,          State.content(&1.assigns.current_user.default_team_id))           )).()
    |> (&(  assign(&1, :content_versions, State.content_versions(&1.assigns.current_user.default_team_id))  )).()
    |> (&(  State.apply_changes(&1, Select.initialize(&1.assigns))                                          )).()
    |> (&(  assign(&1, :current_strategy, &1.assigns.current_version.strategy)                              )).()
    |> (&(  assign(&1, :processes,        State.processes(&1.assigns.current_version.id))                   )).()
    |> (&(  assign(&1, :steps,            State.steps(&1.assigns.current_version.id))                       )).()
    |> (&(  assign(&1, :annotations,      State.annotations(&1.assigns.current_version.id))                 )).()
    |> (&(  assign(&1, :elements,         State.elements(&1.assigns.current_version.id))                    )).()
    |> (&(  assign(&1, :pages,            State.pages(&1.assigns.current_version.id))                       )).()
    |> (&(  assign(&1, :current_processes,Version.processes(&1.assigns.current_version.id, &1.assigns.processes))   )).()
    |> assign(:process_menu, [])
    |> State.report()
  end

  def initialize(%{ assigns: %{ auth_state: _ }} = socket) do
    Logger.debug("User not logged in")
    socket
  end

  def handle_info({:close_modal}, socket) do
    IO.puts("Close modal info")
    { :noreply, close_modal(socket) }
  end

  def close_modal(socket) do
    IO.puts("Close modal function")
    Phoenix.LiveView.send_update(
      ProcessAdministratorWeb.ModalMenus,
      id: "modal-menus",
      action: :show)
    socket
  end

  def call_menu(message, socket) do
    {_, message} = Map.pop(message, :target)

    Phoenix.LiveView.send_update(
      ProcessAdministratorWeb.ModalMenus,
      id: "modal-menus",
      title: message.title,
      object: message.object,
      action: message.action,
      parent: message.parent,
      type: message.type,
      select_lists: message.select_lists
    )

    socket
  end

  def handle_info({:update_current_version, changes}, socket) do
    current_processes =
      UserDocs.Automation.list_processes(%{},
        %{ version_id: changes.current_version.id })

    IO.inspect(changes)
    IO.inspect(current_processes)

    {
      :noreply,
      socket
      |> assign(:current_processes, current_processes)
      |> State.apply_changes(changes)
    }
  end

  # TODO: Must implement either updating the state tree/components
  def handle_info(%{topic: topic, event: event, payload: payload}, socket) do
    Logger.debug("Handling info on topic #{topic}, event #{event}")
    {
      :noreply,
      socket
      |> update_components(topic, event, payload)
      |> execute_preloads(topic, event, payload)
      |> update_socket_data(topic, event, payload)
      |> update_additional_data(topic, event, payload)
    }
  end

  def update_components(socket, "process", _, _) do
    close_modal(socket)
  end
  def update_components(socket, "version", _, _) do
    close_modal(socket)
  end
  def update_components(socket, "project", _, _) do
    close_modal(socket)
  end
  def update_components(socket, _, _, _), do: socket

  def execute_preloads(socket, "process", "create", payload) do
    Logger.debug("Executing Preloads")
    socket
  end
  def execute_preloads(socket, _, _, _), do: socket

  def update_socket_data(socket, topic, "create", payload) do
    Logger.debug("Updating State on topic #{topic}, event create")

    type =
      topic
      |> State.plural()
      |> String.to_atom()

    changes = State.create_object(socket.assigns, type, payload.id, payload)
    # IO.inspect(changes)
    socket = State.apply_changes(socket, changes)
    # IO.puts("Updated assigns")
    socket
  end
  def update_socket_data(socket, topic, "update", payload) do
    Logger.debug("Updating State on topic #{topic}, event update")

    type =
      topic
      |> State.plural()
      |> String.to_atom()

    changes = State.update_object(socket.assigns, type, payload.id, payload)
    State.apply_changes(socket, changes)
  end

  def update_additional_data(socket, "process", _, _) do
    current_processes =
      Version.processes(
        socket.assigns.current_version.id,
        socket.assigns.processes)
      |> Enum.sort(&(&1.order <= &2.order))

    assign(socket, :current_processes, current_processes )
  end
  def update_additional_data(socket, _, _, _) do
    socket
  end
  # TODO: Must implement either updating the state tree/components
  def handle_info(%{topic: topic, event: event, payload: payload}, socket) do
    Logger.debug("Handling a subscription on topic #{topic}, event #{event} old")
    args = String.split(topic, "::")
    type =
      args
      |> Enum.at(0)
      |> State.plural()
      |> String.to_atom

    field =
      try do
        args
        |> Enum.at(1)
        |> String.replace("-", "_")
        |> String.to_atom
      rescue
        _ -> "none"
      end

      Logger.debug("Updating type #{type}, field #{field}")
    socket =
      State.apply_changes(
        socket,
        State.update_object_field(socket.assigns, type, payload.id, field, Map.get(payload, field))
      )

    {:noreply, socket}
  end

  def filter(socket, data_key, { filter_key, value }) do
    socket.assigns
    |> Map.get(data_key)
    |> Enum.filter(fn(o) -> Map.get(o, filter_key) == value end)
  end
  def filter(socket, data_key, {}) do
    socket.assigns
    |> Map.get(data_key)
  end

  def content_class([]), do: "content is-hidden"
  def content_class(_), do: "content"

  @impl true
  def handle_event("new-process", _, socket) do
    IO.puts("New Process")
    {
      :noreply,
      ProcessMessage.new_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  @impl true
  def handle_event("edit-project", _, socket) do
    IO.puts("Edit Project")
    {
      :noreply,
      ProjectMessage.edit_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  @impl true
  def handle_event("new-project", _, socket) do
    IO.puts("New Project")
    {
      :noreply,
      ProjectMessage.new_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  @impl true
  def handle_event("edit-version", _, socket) do
    IO.puts("Edit Versions")
    {
      :noreply,
      VersionMessage.edit_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  @impl true
  def handle_event("new-version", _, socket) do
    IO.puts("New Versions")
    {
      :noreply,
      VersionMessage.new_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  @impl true
  def handle_event("select_team", %{ "team" => %{"id" => id} }, socket) do
    changes = Select.handle_team_selection(socket.assigns, String.to_integer(id))
    {:noreply, State.apply_changes(socket, changes)}
  end

  @impl true
  def handle_event("select_project", %{ "project" => %{"id" => id} }, socket) do
    changes = Select.handle_project_selection(socket.assigns, String.to_integer(id))
    {:noreply, State.apply_changes(socket, changes)}
  end

  @impl true
  def handle_event("select_version", %{ "version" => %{"id" => id} }, socket) do
    changes = Select.handle_version_selection(socket.assigns, String.to_integer(id))
    send(socket.root_pid, {:update_current_version, changes})
    {:noreply, State.apply_changes(socket, changes)}
  end

  def preload_step(step, state, process) do
    element =
      if step.element_id do
        element = Web.get_element!(step.element_id, %{ strategy: true }, %{}, state)
      end

    annotation =
      if step.annotation_id do
        annotation = Web.get_annotation!(step.annotation_id, %{}, %{}, state)

        # TODO: THis guard shouldn't be necessary.  I'm misloading annotations somehow
        if annotation do
          annotation
          |> Map.put(:content, Documents.get_content!(annotation.content_id, %{}, %{}, state.content))
          |> Map.put(:annotation_type, Web.get_annotation_type!(annotation.annotation_type_id, %{}, %{}, state))
        else
          annotation
        end
      end

    step
    |> Map.put(:page, Web.get_page!(step.page_id, %{}, %{}, state))
    |> Map.put(:step_type, Automation.get_step_type!(state.step_types, step.step_type_id))
    |> Map.put(:annotation, annotation)
    |> Map.put(:element, element)
    |> Map.put(:process, process)
  end

  def preload_process(process, state) do
    raw_steps = UserDocs.Automation.list_steps(%{}, %{ process_id: process.id }, state)
    preloaded_steps = Enum.map(raw_steps, &preload_step(&1, state, process))
    process
    |> Map.put(:steps, preloaded_steps)
  end

  @impl true
  def handle_event("login", %{"user" => user_params}, socket) do
    IO.puts("Handling login")
    { :noreply, socket}
  end
end
