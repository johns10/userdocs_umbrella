defmodule UserDocsWeb.ProcessLive.SPA do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users
  alias UserDocs.Automation
  alias UserDocs.Web
  alias UserDocs.Web.Strategy
  alias UserDocs.Documents
  alias UserDocs.Automation.Process
  alias UserDocs.Automation.Step

  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.ProcessLive
  alias UserDocsWeb.StepLive
  alias UserDocsWeb.ProcessLive.Loaders

  def subscribed_types() do
    [
      UserDocs.Automation.Process,
      UserDocs.Automation.Step,
      UserDocs.Documents.Content,
      UserDocs.Documents.ContentVersion,
      UserDocs.Projects.Version,
      UserDocs.Web.Annotation,
      UserDocs.Web.Element,
      UserDocs.Web.Page,
      UserDocs.Media.Screenshot,
    ]
  end

  def extra_types() do
    [
      UserDocs.Documents.LanguageCode,
      UserDocs.Automation.StepType,
      UserDocs.Web.AnnotationType,
      UserDocs.Web.Strategy,
    ]
  end

  @impl true
  def mount(_params, session, socket) do
    opts = Defaults.opts(socket, subscribed_types() ++ extra_types())
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
    opts = Defaults.opts(socket, subscribed_types() ++ extra_types())

    socket
    |> assign(:modal_action, :show)
    |> assign(:transferred_strategy, %Strategy{})
    |> assign(:transferred_selector, "")
    |> ProcessLive.Index.load_processes(opts)
    |> ProcessLive.Index.load_versions(opts)
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Documents.load_language_codes(opts)
    |> Automation.load_step_types(opts)
    |> assign(:mode, :process)
    |> assign(:state_opts, opts)
    |> turn_off_broadcast_associations()
  end

  def turn_off_broadcast_associations(socket) do
    opts = Keyword.put(socket.assigns.state_opts, :broadcast_associations, false)
    assign(socket, :state_opts, opts)
  end

  @impl true
  def handle_params(_, _, %{ assigns: %{ auth_state: :not_logged_in }} = socket) , do: {:noreply, socket}
  def handle_params(%{} = params, _url, socket) do
    opts = socket.assigns.state_opts
    {
      :noreply,
      socket
      |> assign(:current_strategy_id, socket.assigns.current_version.strategy_id)
      |> send_default_strategy()
      |> Loaders.content(opts)
      |> Loaders.content_versions(opts)
      |> StepLive.Index.assign_strategy_id()
      |> apply_action(socket.assigns.live_action, params)
      |> Loaders.processes(opts)
      |> Loaders.steps(opts)
      |> Loaders.annotations(opts)
      |> Loaders.elements(opts)
      |> Loaders.pages(opts)
      |> UserDocsWeb.Loaders.screenshots(opts)
      |> assign(:expanded, %{})
      |> select_lists()
    }
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Processes")
    |> assign(:process, nil)
    |> assign(:step, nil)
    |> prepare_processes()
  end

  @impl true
  def handle_event("select-version" = n, p, s) do
    { :noreply, socket } = Root.handle_event(n, p, s)
    { :noreply, prepare_processes(socket) }
  end
  def handle_event("select-process", %{ "id" => id }, socket) do
    IO.puts("select-process #{id}")
    process = Automation.get_process!(id)
    {
      :noreply,
      socket
      |> assign(:process, process)
      |> assign(:mode, :steps)
      |> StepLive.Index.prepare_steps(String.to_integer(id))
    }
  end
  def handle_event("processes", _params, socket) do
    {
      :noreply,
      socket
      |> assign(:mode, :process)
      |> prepare_processes()
    }
  end
  def handle_event("new-process", _params, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, "New Process")
      |> assign(:live_action, :new)
      |> assign(:process, %Process{})
    }
  end
  def handle_event("new-step", _params, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, "New Step")
      |> assign(:live_action, :new)
      |> assign(:step, %Step{})
    }
  end
  def handle_event("edit-step", %{ "id" => id }, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, "Edit Step")
      |> assign(:mode, :steps)
      |> assign(:live_action, :edit)
      |> StepLive.Index.prepare_step(String.to_integer(id))
    }
  end
  def handle_event("edit-process", %{ "id" => id }, socket) do
    process = Automation.get_process!(String.to_integer(id), socket, socket.assigns.state_opts)
    {
      :noreply,
      socket
      |> assign(:page_title, "Edit Process")
      |> assign(:live_action, :edit)
      |> assign(:process, process)
    }
  end
  def handle_event("delete-process", %{ "id" => id }, socket) do
    process = Automation.get_process!(String.to_integer(id), socket, socket.assigns.state_opts)
    {:ok, deleted_process } = Automation.delete_process(process)
    send(self(), { :broadcast, "delete", deleted_process })
    {:noreply, socket}
  end
  def handle_event("expand" = n, p, s), do: StepLive.Index.handle_event(n, p, s)
  def handle_event("new-content", _params, socket) do
    {:noreply, socket}
  end
  def handle_event("update_current_strategy", %{"current_strategy" => %{ "strategy_id" => id }}, socket) do
    strategy =
      socket.assigns.data.strategies
      |> Enum.filter(fn(s) -> s.id == String.to_integer(id) end)
      |> Enum.at(0)

    message = %{
      type: "configuration",
      payload: %{
        strategy: Strategy.safe(strategy)
      }
    }

    {
      :noreply,
      socket
      |> push_event("configure", message)
      |> assign(:current_strategy, strategy)
    }
  end

  @impl true
  def handle_info({ :close_modal, _ }, socket) do
    { :noreply, assign(socket, :live_action, :show) }
  end
  def handle_info(:close_modal, socket) do
    { :noreply, assign(socket, :live_action, :show) }
  end
  def handle_info(%{ topic: _, event: _, payload: payload } = sub_data, socket) do
    schema =
      case payload do
        %{ objects: [ object | _ ]} -> object.__meta__.schema
        object -> object.__meta__.schema
      end

    { :noreply, socket } = Root.handle_info(sub_data, socket)

    case schema in subscribed_types() do
      true ->
        case { socket.assigns.mode, socket.assigns.live_action } do
          { :steps, :new} ->
            {
              :noreply,
              socket
              |> StepLive.Index.prepare_steps()
              |> select_lists()
            }
          { :steps, :edit} ->
            {
              :noreply,
              socket
              |> StepLive.Index.prepare_steps()
              |> StepLive.Index.prepare_step(socket.assigns.step.id)
              |> select_lists()
            }
          { :steps, :show } ->
            {
              :noreply,
              socket
              |> StepLive.Index.prepare_steps()
            }
          { :process, _ } ->
            {
              :noreply,
              socket
              |> prepare_processes()
              |> select_lists()
            }
          { _, _ } -> { :noreply, socket }
        end
      false -> { :noreply, socket }
    end
  end
  def handle_info({ :transfer_selector, %{ "selector" => selector, "strategy" => strategy } }, socket) do
    strategy =
      Web.list_strategies
      |> Enum.filter(fn(s) -> s.name == strategy end)
      |> Enum.at(0)

    {
      :noreply,
      socket
      |> assign(:transferred_strategy, strategy)
      |> assign(:transferred_selector, selector)
    }
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  def select_lists(socket) do
    select_lists =
      socket
      |> StepLive.Index.select_lists()
      |> Map.merge(ProcessLive.Index.select_lists(socket))

    assign(socket, :select_lists, select_lists)
  end

  def prepare_processes(socket) do
    preloads =
      [
        :processes,
        [ processes: :steps ],
        [ processes: [ steps: :screenshot ] ],
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
      socket.assigns.state_opts
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, order)
      |> Keyword.put(:filter, {:version_id, socket.assigns.current_version.id})

    socket
    |> assign(:processes, Automation.list_processes(socket, opts))
  end

  def send_default_strategy(%{ assigns: %{ current_strategy_id: id }} = socket) do
    #TODO: Use state
    IO.puts("send_default_strategy")
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
end
