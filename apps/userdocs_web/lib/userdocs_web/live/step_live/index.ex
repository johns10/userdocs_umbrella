defmodule UserDocsWeb.StepLive.Index do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Automation
  alias UserDocs.Automation.Step
  alias UserDocs.Web
  alias UserDocs.Web.Element
  alias UserDocs.Users
  alias UserDocs.Projects
  alias UserDocs.Documents
  alias UserDocs.Helpers
  alias UserDocs.Automation.Process
  alias UserDocs.Web.Strategy

  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root
  alias UserDocsWeb.ComposableBreadCrumb
  alias UserDocsWeb.ProcessLive.Loaders

  @subscribed_types [
    UserDocs.Automation.Process,
    UserDocs.Automation.Step,
    UserDocs.Web.Annotation,
    UserDocs.Web.Element,
    UserDocs.Web.Page
  ]

  def types() do
    [
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
  end

  @impl true
  def mount(_params, session, socket) do
    IO.puts("Mounting")
    opts = Defaults.opts(socket, types())
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize(opts)
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :not_logged_in }} = socket), do: socket
  def initialize(socket) do
    opts = Defaults.opts(socket, types())

    socket
    |> assign(:modal_action, :show)
    |> assign(:state_opts, opts)
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Documents.load_language_codes(opts)
    |> Automation.load_step_types(opts)

  end

  @impl true
  def handle_params(_, _, %{ assigns: %{ auth_state: :not_logged_in }} = socket), do: { :noreply, socket }
  def handle_params(%{ "id" => id } = params, _, socket) do
    IO.puts("handle_params")
    {
      :noreply,
      socket
      |> do_handle_params(id)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  def do_handle_params(socket, process_id) do
    opts = Defaults.opts(socket, @subscribed_types)
    process = Automation.get_process!(String.to_integer(process_id))
    socket
    |> assign(:process, process)
    |> Loaders.content(opts)
    |> Loaders.content_versions(opts)
    |> assign_strategy_id()
    |> Loaders.processes(opts)
    |> Loaders.steps(opts)
    |> Loaders.annotations(opts)
    |> Loaders.elements(opts)
    |> Loaders.pages(opts)
    |> assign(:expanded, %{})
    |> prepare_process()
    |> assign_select_lists()
    |> assign(:state_opts, opts)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Step")
    |> assign(:step, %Step{})
    |> assign(:select_lists, select_lists(socket))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Steps")
    |> assign(:step, nil)
    |> assign(:processes, prepare_process(socket))
  end

  @impl true
  def handle_event("expand", %{ "id" => id }, %{ assigns: assigns } = socket) do
    id = String.to_integer(id)
    status = Map.get(assigns.expanded, id, false)
    expanded = Map.put(assigns.expanded, id, !status)
    { :noreply, assign(socket, :expanded, expanded) }
  end

  @impl true
  def handle_info(%{topic: _, event: _, payload: %Step{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_process(socket) }
  end
  def handle_info(%{topic: _, event: _, payload: %Element{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_process(socket) }
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  def assign_select_lists(socket), do: assign(socket, :select_lists, select_lists(socket))

  def select_lists(socket) do
    %{
      annotation_types: annotation_types_select(socket),
      content: content_select(socket),
      processes_select: processes_select(socket),
      step_types_select: step_types_select(socket),
      pages_select: pages_select(socket),
      strategies: strategies_select(socket),
      versions: versions_select(socket)
    }
  end

  def annotation_types_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Web.list_annotation_types(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def annotation_types_select(_), do: []

  def content_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Documents.list_content(socket, state_opts)
    |> Helpers.select_list(:name, :true)
  end
  def content_select(_), do: []

  def processes_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Automation.list_processes(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def processes_select(_), do: []

  def step_types_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Automation.list_step_types(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def step_types_select(_), do: []

  def pages_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Web.list_pages(socket, state_opts)
    |> Helpers.select_list(:name, :true)
  end
  def pages_select(_), do: []

  def strategies_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Web.list_strategies(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def strategies_select(_), do: []

  def versions_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Projects.list_versions(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end


  def assign_strategy_id(%{ assigns: %{ current_version: version }} = socket) do
    assign(socket, :strategy_id, version.strategy_id)
  end

  def send_default_strategy(%{ assigns: %{ current_strategy_id: id }} = socket) do
    strategy =
      Web.list_strategies()
      |> Enum.filter(fn(s) -> s.id == id end)
      |> Enum.at(0)

    message = %{
      type: "configuration",
      payload: %{
        strategy: Strategy.safe(strategy)
      }
    }

    socket
    |> push_event("configure", message)
    |> assign(:current_strategy, strategy)
  end

  def prepare_process(%{ assigns: %{ process: %{ id: id }}} = socket), do: prepare_process(socket, id)
  def prepare_process(socket, process_id) do
    preloads =
      [
        :steps,
        [ steps: :step_type ],
        [ steps: :page ],
        [ steps: :annotation ],
        [ steps: [ annotation: :annotation_type ] ],
        [ steps: :element ],
        [ steps: [ element: :strategy ] ],
      ]

    order = [ steps: %{ field: :order, order: :asc } ]

    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, order)

    assign(socket, :process, Automation.get_process!(process_id, socket, opts))
  end
end
