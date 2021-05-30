defmodule UserDocsWeb.StepLive.Index do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocs.Automation
  alias UserDocs.Automation.Step
  alias UserDocs.Web
  alias UserDocs.Projects
  alias UserDocs.Documents
  alias UserDocs.Helpers
  alias UserDocs.Web.Strategy
  alias UserDocs.Media.Screenshot
  alias UserDocs.Automation.Process.RecentPage

  alias UserDocsWeb.Root
  alias UserDocsWeb.ComposableBreadCrumb
  alias UserDocsWeb.ProcessLive.Loaders
  alias UserDocsWeb.StepLive.Queuer
  alias UserDocsWeb.StepLive.Runner
  alias UserDocsWeb.StepLive.Status
  alias UserDocs.Automation.Process.RecentPage

  def types() do
    [
      UserDocs.Web.AnnotationType,
      UserDocs.Web.Strategy,
      UserDocs.Projects.Version,
      UserDocs.Documents.Content,
      UserDocs.Documents.LanguageCode,
      UserDocs.Automation.StepType,
      UserDocs.Automation.Process,
      UserDocs.Automation.Step,
      UserDocs.Web.Annotation,
      UserDocs.Web.Element,
      UserDocs.Web.Page,
      UserDocs.Media.Screenshot,
      UserDocs.StepInstances.StepInstance
    ]
  end

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, types())
      |> assign(:sidebar_open, false)
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :not_logged_in }} = socket), do: socket
  def initialize(socket) do
    opts = socket.assigns.state_opts
    socket
    |> assign(:modal_action, :show)
    |> assign(:transferred_selector, "")
    |> assign(:transferred_strategy, %{ name: "", id: ""})
    |> UserDocsWeb.Loaders.screenshots(opts)
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Documents.load_language_codes(opts)
    |> Automation.load_step_types(opts)
    |> Loaders.step_instances(opts)
    |> Loaders.steps(opts)
    |> Loaders.processes(opts)
    |> Loaders.pages(opts)
    |> Loaders.content(opts)
    |> Loaders.annotations(opts)
    |> Loaders.elements(opts)
    |> Loaders.screenshots(opts)
    |> UserDocsWeb.Loaders.versions()
    |> turn_off_broadcast_associations()
  end

  def turn_off_broadcast_associations(socket) do
    opts = Keyword.put(socket.assigns.state_opts, :broadcast_associations, false)
    assign(socket, :state_opts, opts)
  end

  @impl true
  def handle_params(_, _, %{ assigns: %{ auth_state: :not_logged_in }} = socket), do: { :noreply, socket }
  def handle_params(%{ "process_id" => process_id } = params, _, socket) do
    process = Automation.get_process!(process_id)
    {
      :noreply,
      socket
      |> assign(:process, process)
      |> prepare_steps(String.to_integer(process_id))
      |> assign(:select_lists, %{})
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  def handle_params(%{ "id" => id } = params, _, socket) do
    {
      :noreply,
      socket
      |> prepare_step(String.to_integer(id))
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    step = Automation.get_step!(String.to_integer(id))
    {:ok, deleted_step } = Automation.delete_step(step)
    send(self(), { :broadcast, "delete", deleted_step })
    {:noreply, socket}
  end

  @impl true
  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Process")
    |> prepare_step(String.to_integer(id))
    |> assign_select_lists()
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
  end

  defp apply_action(socket, :screenshot_workflow, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Process")
    |> prepare_step(String.to_integer(id))
    |> assign_select_lists()
  end

  @impl true
  def handle_info(%{topic: _, event: _, payload: %UserDocs.Documents.Content{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    {
      :noreply,
      socket
      |> assign(:select_lists, select_lists(socket))
    }
  end
  def handle_info(%{topic: _, event: _, payload: %Step{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received a step broadcast")
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_steps(socket) }
  end
  def handle_info(%{topic: _, event: _, payload: %UserDocs.StepInstances.StepInstance{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received a step Instance broadcast")
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_steps(socket) }
  end
  def handle_info(%{topic: _, event: _, payload: %Screenshot{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received a screenshot broadcast")
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    if socket.assigns.step do
      { :noreply, socket |> prepare_step(socket.assigns.step.id) }
    else
      { :noreply, socket |> prepare_steps() }
    end
  end
  def handle_info(%{topic: _, event: _, payload: %UserDocs.Web.Annotation{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received an annotation broadcast")
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_steps(socket) }
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
    |> Helpers.select_list(:name, :true)
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

  def prepare_step(socket, id) do
    preloads =
      [
        :step_type,
        :screenshot,
        :page,
        :annotation,
        :element,
        :process,
        :step_instances,
        [ annotation: :annotation_type ],
        [ annotation: :content ],
        [ element: :strategy ],
      ]

    order = [ %{ field: :order, order: :asc }, step_instances: %{ field: :id, order: :desc} ]
    limit = [ step_instances: 5 ]

    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, order)
      |> Keyword.put(:limit, limit)

    step = Automation.get_step!(id, socket, opts)

    socket
    |> assign(:step, step)
    |> assign(:process, step.process)
    |> prepare_steps(step.process_id) # This has to go
  end

  def prepare_steps(%{ assigns: %{ process: %{ id: id }}} = socket), do: prepare_steps(socket, id)
  def prepare_steps(socket, process_id) do
    preloads =
      [
        :step_type,
        :screenshot,
        :page,
        :annotation,
        :element,
        :step_instances,
        [ annotation: :content ],
        [ annotation: :annotation_type ],
        [ element: :strategy ],
      ]

    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, [ %{ field: :order, order: :asc }, step_instances: %{ field: :id, order: :desc} ])
      |> Keyword.put(:limit,  [ step_instances: 5 ])
      |> Keyword.put(:filter, { :process_id, process_id })

    assign(socket, :steps, Automation.list_steps(socket, opts))
  end
end
