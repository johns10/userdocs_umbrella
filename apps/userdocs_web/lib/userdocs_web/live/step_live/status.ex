defmodule UserDocsWeb.StepLive.Status do
  use UserDocsWeb, :live_slime_component
  use Phoenix.HTML

  alias UserDocs.Screenshots

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:errors, [])
      |> assign(:status, :ok)
      |> assign(:display_errors_modal, false)
    }
  end

  @impl true
  def handle_event("toggle_errors_modal", _, socket) do
    { :noreply, socket |> assign(:display_errors_modal, not socket.assigns.display_errors_modal)}
  end

  def screenshot_status_element(socket, screenshot) do
    kwargs = [
      to: Routes.step_index_path(socket, :screenshot_workflow, screenshot.step_id),
      class: "navbar-item has-tooltip-left",
      data_tooltip: "Screenshot has changed, click warning to review changes."
    ]

    link(kwargs) do
      status_icon(Screenshots.get_screenshot_status(screenshot))
    end
  end

  def step_instances_status_element(_socket, [ _ | _ ] = step_instances, cid) do
    kwargs = [
      to: "#", phx_target: cid,
      phx_click: "toggle_errors_modal",
      class: "navbar-item has-tooltip-left",
      data_tooltip: "One or more step instances failed their last execution. Click for a summary."
    ]

    link(kwargs) do
      status_icon(step_instances_status(step_instances))
    end
  end

  def status_icon(:ok), do: content_tag(:i, "", [class: "fa fa-check", aria_hidden: "true"])
  def status_icon(:failed), do: content_tag(:i, "", [class: "fa fa-times", aria_hidden: "true"])
  def status_icon(:warn), do: content_tag(:i, "", [class: "fas fa-exclamation-triangle", aria_hidden: "true"])
  def status_icon(:started), do: content_tag(:i, "", [class: "fa fa-spinner", aria_hidden: "true"])
  def status_icon(:complete), do: content_tag(:i, "", [class: "fa fa-check", aria_hidden: "true"])

  def render_errors(errors) do
    Enum.reduce(errors, "",
      fn(error, acc) ->
        acc <> render_error(error)
      end
    )
  end

  def render_error(error) do
    Enum.reduce(error, "",
      fn({ k, v }, acc ) ->
        acc <> k <> ": " <> to_string(v) <> "\n"
      end
    )
  end

  def step_instances_status([ _ ] = items) do
    Enum.reduce(items, :ok, fn(step_instance, acc) ->
      case step_instance.status do
        "failed" ->
          :warn
        _ ->
          acc
      end
    end)
  end
  def step_instances_status([]), do: :ok
end
