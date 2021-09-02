defmodule UserDocsWeb.StepLive.Status do
  use UserDocsWeb, :live_slime_component
  use Phoenix.HTML

  alias UserDocs.StepInstances
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
    {:noreply, socket |> assign(:display_errors_modal, not socket.assigns.display_errors_modal)}
  end

  def screenshot_status_element(socket, screenshot) do
    kwargs = [
      to: Routes.step_index_path(socket, :screenshot_workflow, screenshot.step_id),
      class: "navbar-item has-tooltip-left",
      data_tooltip: "Screenshot has changed, click warning to review changes."
    ]

    icon_kwargs =
      [aria_hidden: "true"]
      |> icon_kwargs(Screenshots.get_screenshot_status(screenshot))

    link(kwargs) do
      content_tag(:i, "", icon_kwargs)
    end
  end

  def step_instances_status_element(_socket, step_instances, cid) when is_list(step_instances) do
    status = StepInstances.step_instances_status(step_instances)
    tag_kwargs =
      [
        to: "#", phx_target: cid,
        phx_click: "toggle_errors_modal",
        class: tag_class(status),
        style: "cursor: pointer;"
      ]

    icon_kwargs =
      [aria_hidden: "true"]
      |> icon_kwargs(status)

    content_tag(:div, [class: "control"]) do
      content_tag(:div, [class: "tags has-addons"]) do
        [
          content_tag(:span, [class: "tag"]) do
            [
              StepInstances.count_status(step_instances, "complete") |> to_string(),
              "/",
              Enum.count(step_instances) |> to_string()
            ]
          end,
          content_tag(:span, tag_kwargs) do
            content_tag(:i, "", icon_kwargs)
          end
        ]
      end
    end
  end

  def icon_kwargs(base, :none), do: base ++ [class: "fa fa-check"]
  def icon_kwargs(base, :warn), do: base ++ [class: "fas fa-exclamation-triangle"]
  def icon_kwargs(base, :ok), do: base ++ [class: "fa fa-check"]
  def icon_kwargs(base, :fail), do: base ++ [class: "fa fa-times"]
  def icon_kwargs(base, :started), do: base ++ [class: "fa fa-spinner"]
  def icon_kwargs(base, :complete), do: base ++ [class: "fa fa-check"]

  def tag_class(:none), do: "tag"
  def tag_class(:warn), do: "tag is-warning"
  def tag_class(:ok), do: "tag is-success"
  def tag_class(:fail), do: "tag is-danger"
  def tag_class(:started), do: "tag is-success"
  def tag_class(:complete), do:  "tag is-success"

  def render_errors(nil), do: ""
  def render_errors(errors) do
    Enum.reduce(errors, "",
      fn(error, acc) ->
        acc <> render_error(error)
      end
    )
  end

  def render_error(error) do
    Enum.reduce(error, "",
      fn({k, v}, acc ) ->
        acc <> to_string(k) <> ": " <> to_string(v) <> "\n"
      end
    )
  end

  def step_instances_status([_ | _] = items) do
    Enum.reduce(items, nil, fn(step_instance, acc) ->
      case step_instance.status do
        "failed" -> :warn
        "not_started" -> :warn
        _ -> acc
      end
    end)
  end
  def step_instances_status([]), do: :ok
end
