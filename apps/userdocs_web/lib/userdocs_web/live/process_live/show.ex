defmodule UserDocsWeb.ProcessLive.Show do
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
  alias UserDocs.Automation.Process.RecentPage

  alias UserDocsWeb.StepLive.Runner
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root
  alias UserDocsWeb.StepLive.FormComponent, as: StepForm

  alias UserDocsWeb.ProcessLive.Loaders

  @subscribed_types [
    UserDocs.Automation.Process,
    UserDocs.Automation.Step,
    UserDocs.Web.Annotation,
    UserDocs.Web.Element,
    UserDocs.Web.Page
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

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize(Defaults.base_opts(@types))
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = Defaults.state_opts(socket)

    socket
    |> assign(:modal_action, :show)
    |> assign(:state_opts, opts)
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Documents.load_language_codes(opts)
    |> Automation.load_step_types(opts)

  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(%{ "id" => id, "team_id" => team_id, "project_id" => project_id, "version_id" => version_id }, _, socket) do
    opts = Defaults.opts(socket, @subscribed_types)
    process = Automation.get_process!(String.to_integer(id))
    {
      :noreply,
      socket
      |> assign(:team, Users.get_team!(team_id))
      |> assign(:project, Projects.get_project!(project_id))
      |> assign(:version, Projects.get_version!(version_id))
      |> assign(:page_title, page_title(socket.assigns.live_action))
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
    }
  end

  @impl true
  def handle_event("expand", %{ "id" => id }, %{ assigns: assigns } = socket) do
    id = String.to_integer(id)
    status = Map.get(assigns.expanded, id, false)
    expanded = Map.put(assigns.expanded, id, !status)
    { :noreply, assign(socket, :expanded, expanded) }
  end

  @imple true
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

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

  defp page_title(:show), do: "Show Project"
  defp page_title(:edit), do: "Edit Project"

  def assign_select_lists(socket), do: assign(socket, :select_lists, select_lists(socket))

  def select_lists(socket) do
    %{
      processes_select: processes_select(socket),
      step_types_select: step_types_select(socket),
      pages_select: pages_select(socket),
      strategies: strategies_select(socket),
      annotation_types: annotation_types_select(socket),
      content: content_select(socket)
    }
  end

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
    |> Helpers.select_list(:name, :false)
  end
  def pages_select(_), do: []

  def elements_select(%{ assigns: %{ state_opts: state_opts }} = socket, step) do
    Web.list_elements(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def elements_select(_, _), do: []

  def strategies_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Web.list_strategies(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def strategies_select(_), do: []

  def annotation_types_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Web.list_annotation_types(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def annotation_types_select(_), do: []

  def content_select(%{ assigns: %{ state_opts: state_opts }} = socket) do
    Documents.list_content(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def content_select(_), do: []

  def annotations_select(%{ assigns: %{ state_opts: state_opts }} = socket, step) do
    opts = Keyword.put(state_opts, :filter, { :page_id, step.page_id} )

    Web.list_annotations(socket, opts)
    |> Helpers.select_list(:name, :false)
  end
  def annotations_select(_, _), do: []

  defp select_lists() do
    %{
      strategies:
        Web.list_strategies()
        |> Helpers.select_list(:name, false),
    }
  end

  def is_expanded?(expanded, id) do
    Map.get(expanded, id, false)
    |> case do
      true -> ""
      false -> "is-hidden"
    end
  end

  def assign_strategy_id(%{ assigns: %{ version: version }} = socket) do
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

  def prepare_process(socket) do
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

    assign(socket, :process, Automation.get_process!(socket.assigns.current_version.id, socket, opts))
  end
end
