defmodule UserDocsWeb.ProcessAdministratorLive.Index do
  use UserDocsWeb, :live_view

  require Logger

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocsWeb.ID
  alias UserDocsWeb.ProcessLive
  alias UserDocsWeb.StepLive
  alias UserDocsWeb.ProcessAdministratorLive.Loaders

  alias UserDocsWeb.ModalMenus, as: ModalMenus

  alias UserDocs.Automation.Step
  alias UserDocs.Web
  alias UserDocs.Web.Strategy
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Projects.Select
  alias UserDocs.Documents
  alias UserDocs.Projects.Select

  alias UserDocsWeb.CollapsableFormComponent
  alias UserDocsWeb.GroupComponent
  alias UserDocsWeb.Root

  @subscribed_types [
    UserDocs.Automation.Process,
    UserDocs.Automation.Step,
    UserDocs.Web.Annotation,
    UserDocs.Web.Element
  ]

  @types [
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

  defp base_opts() do
    UserDocsWeb.Defaults.state_opts()
    |> Keyword.put(:location, :data)
    |> Keyword.put(:types, @types)
  end

  defp state_opts(socket) do
    base_opts()
    |> Keyword.put(:broadcast, true)
    |> Keyword.put(:channel, UserDocsWeb.Defaults.channel(socket))
    |> Keyword.put(:broadcast_function, &UserDocsWeb.Endpoint.broadcast/3)
  end

  @impl true
  def mount(_params, session, socket) do
    # Get Data from the Database
    Logger.debug("DB operations")
    opts = base_opts()

    socket =
      socket
      |> Root.authorize(session)
      |> Root.initialize(opts)
      |> initialize()
      |> assign(:form_data, %{ action: :show })

    {:ok, socket}
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = state_opts(socket)

    socket
    |> assign(:modal_action, :show)
    |> assign(:transferred_strategy, %Strategy{})
    |> assign(:transferred_selector, "")
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Documents.load_language_codes(opts)
    |> Automation.load_step_types(opts)
    |> Loaders.content(opts)
    |> Loaders.content_versions(opts)
    |> Select.assign_default_strategy_id(&assign/3, opts)
    |> Loaders.processes(opts)
    |> Loaders.steps(opts)
    |> Loaders.annotations(opts)
    |> Loaders.elements(opts)
    |> Loaders.pages(opts)
    |> prepare_version()
    |> assign(:process_menu, [])
    |> assign(:state_opts, opts)
  end
  def initialize(socket), do: socket
  @impl true
  def handle_info(%{topic: _, event: _, payload: payload} = sub_data, socket) do
    case is_in_list(payload, @subscribed_types) do
      true ->
        { :noreply, socket } = Root.handle_info(sub_data, socket)
        { :noreply, prepare_version(socket) }
      false ->
        { :noreply, socket }

    end
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  def is_in_list(item, list) do
    Enum.reduce(list, false,
      fn(type, acc) ->
        case is_struct(item, type) do
          true -> true
          false -> acc
        end
      end
    )
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
  def handle_event("edit-project", _, socket), do: ModalMenus.edit_project(socket)
  def handle_event("new-project", _, socket), do: ModalMenus.new_project(socket)
  def handle_event("edit-version", _, socket), do: ModalMenus.edit_version(socket)
  def handle_event("new-version", _, socket), do: ModalMenus.new_version(socket)
  def handle_event("update_current_strategy", %{"current_strategy" => %{ "strategy_id" => _id }}, socket) do
    IO.puts("Updating Current Strategy")

    {
      :noreply,
      socket
    }
  end
  def handle_event("new-step" = name, %{ "process-id" => process_id }, socket) do
    process_id = String.to_integer(process_id)
    opts = Keyword.put(socket.assigns.state_opts, :preloads, [ :steps ])
    params =
      %{}
      |> Map.put(:process_id, process_id)
      |> Map.put(:process, Automation.get_process!(process_id, socket, opts))
      |> Map.put(:processes, Automation.list_processes(socket, socket.assigns.state_opts))
      |> Map.put(:step_types, Automation.list_step_types(socket, socket.assigns.state_opts))
      |> Map.put(:annotation_types, Web.list_annotation_types(socket, socket.assigns.state_opts))
      |> Map.put(:state_opts, socket.assigns.state_opts)

    Root.handle_event(name, params, socket)
  end
  def handle_event("new-process" = name, %{ "current-project-id" => project_id, "current-version-id" => version_id }, socket) do
    params =
      %{}
      |> Map.put(:project_id, String.to_integer(project_id))
      |> Map.put(:version_id, String.to_integer(version_id))
      |> Map.put(:versions, Projects.list_versions(socket, socket.assigns.state_opts))

    Root.handle_event(name, params, socket)
  end

  def prepare_version(socket) do
    IO.puts("Preparing Version")
    preloads =
      [
        :processes,
        [ processes: :steps ],
        [ processes: [ steps: :step_type ] ],
        [ processes: [ steps: :page ] ],
        [ processes: [ steps: :annotation ] ],
        [ processes: [ steps: [ annotation: :annotation_type ] ] ],
        [ processes: [ steps: :element ] ],
        [ processes: [ steps: [ element: :strategy ] ] ],
      ]

    order =
      [
        processes: %{ field: :name, order: :asc },
        processes: [ steps: %{ field: :order, order: :asc } ]
      ]

    opts =
      state_opts(socket)
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, order)

    assign(socket, :current_version, Projects.get_version!(socket.assigns.current_version_id, socket, opts))
  end
end
