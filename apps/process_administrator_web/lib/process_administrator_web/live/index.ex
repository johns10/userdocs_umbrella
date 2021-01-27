defmodule ProcessAdministratorWeb.IndexLive do
  @behaviour Gettext.Plural
  require Logger

  use ProcessAdministratorWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias ProcessAdministratorWeb.Endpoint
  alias ProcessAdministratorWeb.ID
  alias ProcessAdministratorWeb.State
  alias ProcessAdministratorWeb.ProcessLive
  alias ProcessAdministratorWeb.StepLive
  alias ProcessAdministratorWeb.LiveHelpers
  alias ProcessAdministratorWeb.Loaders

  alias UserDocsWeb.ModalMenus, as: ModalMenus

  alias UserDocs.Automation.Step
  alias UserDocs.Web
  alias UserDocs.Users
  alias UserDocs.Web.Strategy
  alias UserDocs.Projects.Version
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Projects.Select
  alias UserDocs.Projects.Version
  alias UserDocs.Documents
  alias UserDocs.Projects.Select

  alias ProcessAdministratorWeb.State

  alias UserDocsWeb.Root

  @types_to_initialize [
    UserDocs.Web.AnnotationType,
    UserDocs.Web.Strategy,
    UserDocs.Documents.LanguageCode,
    UserDocs.Automation.StepType,
    UserDocs.Documents.Content,
    UserDocs.Documents.ContentVersion,
    UserDocs.Automation.Process,
    UserDocs.Automation.Step,
    UserDocs.Web.Annotation,
    UserDocs.Web.Element,
    UserDocs.Web.Page
  ]

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
    opts =
      state_opts()
      |> Keyword.put(:types, @types_to_initialize)

    socket =
      socket
      |> Root.authorize(session)
      |> Root.initialize(opts)
      |> initialize()
      |> assign(:form_data, %{ action: :show })

    {:ok, socket}
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    socket
    |> assign(:modal_action, :show)
    |> assign(:transferred_strategy, %Strategy{})
    |> assign(:transferred_selector, "")
    |> Web.load_annotation_types(state_opts())
    |> Web.load_strategies(state_opts())
    |> Documents.load_language_codes(state_opts())
    |> Automation.load_step_types(state_opts())
    |> Loaders.content(state_opts())
    |> Loaders.content_versions(state_opts())
    |> Select.assign_default_strategy_id(&assign/3, state_opts())
    |> Loaders.processes(state_opts())
    |> Loaders.steps(state_opts())
    |> Loaders.annotations(state_opts())
    |> Loaders.elements(state_opts())
    |> Loaders.pages(state_opts())
    |> legacy_object_assigner(state_opts())
    |> current_processes()
    |> prepare_version()
    |> assign(:process_menu, [])
    |> assign(:state_opts, state_opts())
    |> State.report()
  end

  def initialize(%{ assigns: %{ auth_state: _ }} = socket) do
    Logger.debug("User not logged in")
    socket
  end

  def handle_info({:close_modal}, socket), do: { :noreply, ModalMenus.close(socket) }
  def handle_info({:update_current_version, changes}, socket) do
    current_processes =
      UserDocs.Automation.list_processes(%{},
        %{ version_id: changes.current_version.id })

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

  def update_components(socket, "process", _, _), do: ModalMenus.close(socket)
  def update_components(socket, "version", _, _), do: ModalMenus.close(socket)
  def update_components(socket, "project", _, _), do: ModalMenus.close(socket)
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
    State.apply_changes(socket, changes)
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

  def update_additional_data(socket, "step", _, _) do
    Logger.debug("Updating Additional Data on receipt of process")
    sorted_steps =
      socket.assigns.steps
      |> Enum.sort(&(&1.order <= &2.order))

    socket
    |> assign(:steps, sorted_steps)
    |> current_processes()
  end
  def update_additional_data(socket, "process", _, _) do
    Logger.debug("Updating Additional Data on receipt of process")
    sorted_steps =
      socket.assigns.steps
      |> Enum.sort(&(&1.order <= &2.order))

    socket
    |> assign(:steps, sorted_steps)
    |> current_processes()
  end
  def update_additional_data(socket, _, _, _) do
    socket
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
  def handle_event("new-process", _, socket), do: ModalMenus.new_process(socket)
  def handle_event("edit-project", _, socket), do: ModalMenus.edit_project(socket)
  def handle_event("new-project", _, socket), do: ModalMenus.new_project(socket)
  def handle_event("edit-version", _, socket), do: ModalMenus.edit_version(socket)
  def handle_event("new-version", _, socket), do: ModalMenus.new_version(socket)
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
  def handle_event("select-version", %{ "version" => %{"id" => id} }, socket) do
    changes = Select.handle_version_selection(socket.assigns, String.to_integer(id))
    send(socket.root_pid, {:update_current_version, changes})
    {:noreply, State.apply_changes(socket, changes)}
  end
  @impl true
  def handle_event("update_current_strategy", %{"current_strategy" => %{ "strategy_id" => _id }}, socket) do
    IO.puts("Updating Current Strategy")

    {
      :noreply,
      socket
    }
  end

  def preload_step(step, state, process) do
    opts = [ data_type: :list, strategy: :by_type ]

    element =
      if step.element_id do
        Web.get_element!(step.element_id, %{ strategy: true }, %{}, state)
      end

    annotation =
      if step.annotation_id do
        annotation = Web.get_annotation!(step.annotation_id, %{}, %{}, state)

        # TODO: THis guard shouldn't be necessary.  I'm misloading annotations somehow
        if annotation do
          annotation
          |> Map.put(:content, Documents.get_content!(annotation.content_id, state, opts))
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
    opts = [ data_type: :list, strategy: :by_type, filter: {:process_id, process.id} ]
    raw_steps = UserDocs.Automation.list_steps(state, opts)
    preloaded_steps = Enum.map(raw_steps, &preload_step(&1, state, process))
    process
    |> Map.put(:steps, preloaded_steps)
  end

  def current_processes(socket) do
    processes =
      Version.processes(socket.assigns.current_version_id, socket.assigns.processes)
      |> Enum.map(fn(p) -> preload_process(p, socket.assigns) end)

    assign(socket, :current_processes, processes)
  end

  def prepare_version(socket) do
    IO.puts("Preparing Version")
    preloads =
      [
        :processes,
        [ processes: :steps ],
        [ processes: [ steps: :step_type ] ],
        [ processes: [ steps: :page ] ]
      ]


    opts =
      state_opts()
      |> Keyword.put(:preloads, preloads)

    assign(socket, :current_version, Projects.get_version!(socket.assigns.current_version_id, socket, opts))
  end

  defp legacy_object_assigner(socket, opts) do
    socket
    |> assign(:current_team, Users.get_user!(socket.assigns.current_user.id, %{}, %{}, socket, opts))
    |> assign(:current_project, Projects.get_project!(socket.assigns.current_project_id, socket, opts))
    |> assign(:current_version, Projects.get_version!(socket.assigns.current_version_id, socket, opts))
  end

  defp state_opts() do
    UserDocsWeb.Defaults.state_opts()
  end
end
