defmodule UserDocsWeb.StepLive.Index do
  @moduledoc """
    Index file for the Step Datatype
  """
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocs.Automation
  alias UserDocs.Automation.Step
  alias UserDocs.Documents
  alias UserDocs.Helpers
  alias UserDocs.Media.Screenshot
  alias UserDocs.Projects
  alias UserDocs.Web

  alias UserDocsWeb.StepLive.BrowserEvents
  alias UserDocsWeb.ComposableBreadCrumb
  alias UserDocsWeb.ProcessLive.Loaders
  alias UserDocsWeb.ProcessLive
  alias UserDocsWeb.Root
  alias UserDocsWeb.StepLive
  alias UserDocsWeb.ScreenshotLive.Approve

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, data_types())
      |> initialize()
   }
  end

  def initialize(%{assigns: %{auth_state: :not_logged_in}} = socket), do: socket
  def initialize(socket) do
    opts = socket.assigns.state_opts
    socket
    |> assign(:modal_action, :show)
    |> assign(:step_params, nil)
    |> UserDocsWeb.Loaders.screenshots(opts)
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Automation.load_step_types(opts)
    |> Loaders.step_instances(opts)
    |> Loaders.steps(opts)
    |> Loaders.processes(opts)
    |> Loaders.pages(opts)
    |> Loaders.annotations(opts)
    |> Loaders.elements(opts)
    |> Loaders.screenshots(opts)
    |> Loaders.projects(opts)
    |> turn_off_broadcast_associations()
  end

  def turn_off_broadcast_associations(socket) do
    opts = Keyword.put(socket.assigns.state_opts, :broadcast_associations, false)
    assign(socket, :state_opts, opts)
  end

  @impl true
  def handle_params(_, _, %{assigns: %{auth_state: :not_logged_in}} = socket), do: {:noreply, socket}
  def handle_params(%{"process_id" => process_id, "step_params" => _} = params, _, socket) do
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
  def handle_params(%{"process_id" => process_id} = params, _, socket) do
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
  def handle_params(%{"id" => id, "step_params" => _} = params, _, socket) do
    {
      :noreply,
      socket
      |> prepare_step(String.to_integer(id))
      |> apply_action(socket.assigns.live_action, params)
   }
  end
  def handle_params(%{"id" => id} = params, _, socket) do
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
    {:ok, deleted_step} = Automation.delete_step(step)
    send(self(), {:broadcast, "delete", deleted_step})
    {:noreply, socket}
  end
  def handle_event("select-project" = n, p, s) do
    {:noreply, socket} = Root.handle_event(n, p, s)
    {:noreply, redirect(socket, to: Routes.process_index_path(socket, :index))}
  end
  def handle_event("fix_order", _, socket) do
    #IO.puts("Fixing order")
    {steps, _} = Enum.map_reduce(socket.assigns.steps, 0, fn(step, acc) ->
      {:ok, step} = Automation.update_step(step, %{order: acc})
      {step, acc + 1}
    end)
    {:noreply, assign(socket, :steps, steps)}
  end
  def handle_event("reorder_start", %{"id" => step_id}, socket) do
    #IO.puts("Starting Drag")
    step = Automation.get_step!(String.to_integer(step_id), socket, get_step_opts(socket))
    {:noreply, socket |> assign(:drag, step) |> assign(:items, socket.assigns.steps)}
  end
  def handle_event("reorder_dragenter", %{"step-id" => ""}, socket) do
    {:noreply, socket}
  end
  def handle_event("reorder_dragenter", %{"order" => to_order}, socket) do
    drag = socket.assigns.drag
    Logger.debug("Reordering #{drag.name} from #{drag.order} to #{to_order}, #{drag.id}")
    steps = move(socket.assigns.items, drag, String.to_integer(to_order)) |> Enum.sort(&(&1.order < &2.order))
    {:noreply, assign(socket, :steps, steps)}
  end
  def handle_event("reorder_dragenter", _, socket), do: {:noreply, socket}
  def handle_event("reorder_end", _, socket) do
    Logger.debug("Reordering steps")
    steps = Enum.map(socket.assigns.steps, fn(updated_step) ->
      original_step = Automation.get_step!(updated_step.id, socket.assigns, socket.assigns.state_opts)
      {:ok, step} = Automation.update_step(original_step, %{order: updated_step.order})
      step
    end)
    send(self(), {:broadcast, "update", %{objects: steps}})
    {:noreply, socket |> assign(:drag, nil) |> assign(:items, nil)}
  end
  def handle_event("reorder_dragend", _, %{assigns: %{drag: nil}} = socket),
    do: {:noreply, socket}
  def handle_event("reorder_dragend", _, %{assigns: %{drag: _, items: items}} = socket),
    do: {:noreply, socket |> assign(:drag, nil) |> assign(:steps, items)}

  @impl true
  def handle_info(%{topic: "user:" <> user_id, event: "event:browser_event", payload: %{"action" => action} = payload}, socket) do
    payload = UserDocsWeb.LiveHelpers.underscored_map_keys(payload)
    state = %{payload: payload, page_id: recent_navigated_page_id(socket)}
    step_params = BrowserEvents.params(state)

    # def guard_action_from_item_selected(live_action, event_action)
    form_action =
      case {socket.assigns.live_action, action} do
        {:index, "ITEM_SELECTED"} -> :new
        {action, _} -> action
      end

    case form_action do
      :index ->
        route = Routes.step_index_path(socket, :new, socket.assigns.process, %{step_params: step_params})
        {:noreply, push_patch(socket, to: route)}
      :new ->
        send_update(UserDocsWeb.StepLive.FormComponent, %{id: "step-form", step_params: step_params})
        {:noreply, socket}
      :edit ->
        send_update(UserDocsWeb.StepLive.FormComponent, %{id: "step-form", step_params: step_params})
        {:noreply, socket}
    end
  end

  # Had to use order ... using id's screws things up, because it's hard to get the orders and id's to sync
  def move(items, %{order: from_order}, to_order) when from_order == to_order do
    items
  end
  def move(items, %{order: from_order}, to_order) when Kernel.abs(from_order - to_order) == 1 do
    Logger.debug("Moving to an adjacent item")
    Enum.map(items, fn(item) ->
      case item.order do
        order when order == from_order -> Map.put(item, :order, to_order)
        order when order == to_order -> Map.put(item, :order, from_order)
        _ -> item
      end
    end)
  end
  def move(items, %{order: from_order}, to_order) when Kernel.abs(from_order - to_order) > 1 do
    Logger.debug("Moving to a non adjacent item")
    args = order_args(from_order, to_order)
    Enum.map(items, fn(item) ->
      case item.order do
        order when order <= args.max and order >= args.min -> Map.put(item, :order, item.order + args.adjustment)
        order when order == from_order -> Map.put(item, :order, to_order)
        _ -> item
      end
    end)

  end

  def order_args(source_order, target_order)
  when source_order < target_order == true do
    %{
      min: source_order + 1,
      max: target_order,
      adjustment: -1
    }
  end

  def order_args(source_order, target_order)
  when source_order < target_order == false do
    %{
      min: target_order,
      max: source_order - 1,
      adjustment: 1
    }
  end

  defp recent_navigated_page_id(socket) do
    socket.assigns.steps
    |> Enum.filter(fn(s) -> s.step_type.name == "Navigate" end)
    |> Enum.max_by(fn(s) -> s.order end)
    |> Map.get(:page_id)
  rescue
    _ -> nil
  end

  defp apply_action(socket, :edit, %{"id" => id, "step_params" => step_params}) when map_size(step_params) > 0 do
    updated_params = Map.merge(step_params, socket.assigns.changeset.params)
    changeset = Map.put(socket.assigns.changeset, :params, updated_params)

    socket
    |> assign(:page_title, "Edit Process")
    |> prepare_step(String.to_integer(id))
    |> assign(:changeset, changeset)
    |> assign_select_lists()
  end
  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Process")
    |> prepare_step(String.to_integer(id))
    |> assign_select_lists()
  end
  defp apply_action(socket, :new, %{"step_params" => step_params}) do
    page_id = recent_navigated_page_id(socket)
    annotation_type_id =
      case step_params do
        %{"annotation" => %{"annotation_type_id" => annotation_type_id}} -> annotation_type_id
        _ -> nil
      end

    label = UserDocs.Automation.automatic_label(socket.assigns.steps)

    step_form =
      %UserDocs.Automation.StepForm{}
      |> Automation.change_step_form(step_params)
      |> Ecto.Changeset.apply_changes()
      |> Map.put(:page_id, page_id)
      |> Map.put(:annotation, %UserDocs.Web.AnnotationForm{page_id: page_id, annotation_type_id: annotation_type_id, label: label})
      |> Map.put(:screenshot, %UserDocs.Media.Screenshot{})
      |> Map.put(:order, UserDocs.Automation.next_order(socket.assigns.steps))

    step =
      %UserDocs.Automation.Step{}
      |> Map.put(:screenshot, %UserDocs.Media.Screenshot{})

    socket
    |> assign(:page_title, "New Step")
    |> assign(:step, step)
    |> assign(:step_form, step_form)
    |> assign(:select_lists, select_lists(socket))
  end
  defp apply_action(socket, :new, _params) do
    page_id = recent_navigated_page_id(socket)
    page =
      case page_id do
        nil -> nil
        page_id -> Web.get_page!(page_id, socket, socket.assigns.state_opts)
      end

    label = UserDocs.Automation.automatic_label(socket.assigns.steps)

    step_form =
      %UserDocs.Automation.StepForm{}
      |> Map.put(:page_id, page_id)
      |> Map.put(:page, page)
      |> Map.put(:element, %UserDocs.Web.Element{page_id: page_id})
      |> Map.put(:annotation, %UserDocs.Web.AnnotationForm{page_id: page_id, label: label})
      |> Map.put(:order, UserDocs.Automation.next_order(socket.assigns.steps))

    step =
      %UserDocs.Automation.Step{}
      |> Map.put(:screenshot, %UserDocs.Media.Screenshot{})

    socket
    |> assign(:page_title, "New Step")
    |> assign(:step, step)
    |> assign(:step_form, step_form)
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
  def handle_info(%{topic: _, event: _, payload: %Step{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received a step broadcast")
    {:noreply, socket} = Root.handle_info(sub_data, socket)
    {:noreply, prepare_steps(socket)}
  end
  def handle_info(%{topic: _, event: _, payload: %UserDocs.StepInstances.StepInstance{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received a step Instance broadcast")
    socket = UserDocsWeb.UserChannelHandlers.apply(socket, sub_data)
    {:noreply, prepare_steps(socket)}
  end
  def handle_info(%{topic: _, event: _, payload: %Screenshot{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received a screenshot broadcast")
    {:noreply, socket} = Root.handle_info(sub_data, socket)
    if socket.assigns.step do
      {:noreply, socket |> prepare_step(socket.assigns.step.id)}
    else
      {:noreply, socket |> prepare_steps()}
    end
  end
  def handle_info(%{topic: _, event: _, payload: %UserDocs.Web.Annotation{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received an annotation broadcast")
    {:noreply, socket} = Root.handle_info(sub_data, socket)
    {:noreply, prepare_steps(socket)}
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  def data_types do
    [
      UserDocs.Web.AnnotationType,
      UserDocs.Web.Strategy,
      UserDocs.Automation.StepType,
      UserDocs.Automation.Process,
      UserDocs.Automation.Step,
      UserDocs.Web.Annotation,
      UserDocs.Web.Element,
      UserDocs.Web.Page,
      UserDocs.Media.Screenshot,
      UserDocs.StepInstances.StepInstance,
      UserDocs.Projects.Project
   ]
  end

  def assign_select_lists(socket), do: assign(socket, :select_lists, select_lists(socket))

  def select_lists(socket) do
    %{
      annotation_types: annotation_types_select(socket),
      processes_select: processes_select(socket),
      step_types_select: step_types_select(socket),
      pages_select: pages_select(socket),
      strategies: strategies_select(socket),
      projects: projects_select(socket)
   }
  end

  def annotation_types_select(%{assigns: %{state_opts: state_opts}} = socket) do
    order = [%{field: :id, order: :asc}]
    opts = Keyword.put(state_opts, :order, order)
    Web.list_annotation_types(socket, opts)
    |> Helpers.select_list(:name, :false)
  end
  def annotation_types_select(_), do: []

  def processes_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Automation.list_processes(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def processes_select(_), do: []

  def step_types_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Automation.list_step_types(socket, state_opts)
    |> Helpers.select_list(:name, :true)
  end
  def step_types_select(_), do: []

  def pages_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Web.list_pages(socket, state_opts)
    |> Helpers.select_list(:name, :true)
  end
  def pages_select(_), do: []

  def strategies_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Web.list_strategies(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
  def strategies_select(_), do: []

  def projects_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Projects.list_projects(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end

  def assign_strategy_id(%{assigns: %{current_project: project}} = socket) do
    assign(socket, :strategy_id, project.strategy_id)
  end

  def get_step_opts(socket) do
    preloads =
      [
        :step_type,
        :screenshot,
        :page,
        [page: :project],
        :annotation,
        :element,
        :process,
        :step_instances,
        [annotation: :annotation_type],
        [element: :strategy],
     ]

     order = [%{field: :order, order: :asc}, step_instances: %{field: :id, order: :desc}]
     limit = [step_instances: 5]

    socket.assigns.state_opts
    |> Keyword.put(:preloads, preloads)
    |> Keyword.put(:order, order)
    |> Keyword.put(:limit, limit)
end

  def prepare_step(socket, id) do
    step = Automation.get_step!(id, socket, get_step_opts(socket))

    annotation_form =
      if step.annotation do
        a = step.annotation
        %Web.AnnotationForm{
          name: a.name,
          label: a.label,
          x_orientation: a.x_orientation,
          y_orientation: a.y_orientation,
          size: a.size,
          color: a.color,
          thickness: a.thickness,
          x_offset: a.x_offset,
          y_offset: a.y_offset,
          font_size: a.font_size,
          page_id: a.page_id,
          annotation_type_id: a.annotation_type_id
       }
      else
        %Web.AnnotationForm{}
      end

    step_form = %Automation.StepForm{
      id: step.id,
      order: step.order,
      name: step.name,
      url: step.url,
      text: step.text,
      width: step.width,
      height: step.height,
      page_id: step.page_id,
      page: step.page,
      element_id: step.element_id,
      element: step.element,
      annotation_id: step.annotation_id,
      annotation: annotation_form,
      screenshot: step.screenshot,
      step_type_id: step.step_type_id,
      process_id: step.process_id
   }

    socket
    |> assign(:step_form, step_form)
    |> assign(:step, step)
    |> assign(:process, step.process)
    |> prepare_steps(step.process_id) # This has to go
  end

  def prepare_steps(%{assigns: %{process: %{id: id}}} = socket), do: prepare_steps(socket, id)
  def prepare_steps(socket, process_id) do
    preloads =
      [
        :step_type,
        :screenshot,
        :page,
        :annotation,
        :element,
        :step_instances,
        [annotation: :annotation_type],
        [element: :strategy],
     ]

    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, [%{field: :order, order: :asc}, step_instances: %{field: :id, order: :desc}])
      |> Keyword.put(:limit,  [step_instances: 5])
      |> Keyword.put(:filter, {:process_id, process_id})

    assign(socket, :steps, Automation.list_steps(socket, opts))
  end
end
