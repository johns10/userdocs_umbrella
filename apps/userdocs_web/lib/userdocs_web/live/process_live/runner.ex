defmodule UserDocsWeb.ProcessLive.Runner do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item"
      id="<%= @id %>"
      phx-click="execute_job"
      phx-value-process-id="<%= @object.id %>"
      phx-target="<%= @myself.cid %>"
      phx-hook="jobRunner"
      status="<%= @status %>"
    >
      <span class="icon">
        <%= case @status do
          :ok -> content_tag(:i, "", [class: "fa fa-play-circle", aria_hidden: "true"])
          :failed -> content_tag(:i, "", [class: "fa fa-times", aria_hidden: "true"])
          :running -> content_tag(:i, "", [class: "fa fa-spinner", aria_hidden: "true"])
          :complete -> content_tag(:i, "", [class: "fa fa-check", aria_hidden: "true"])
        end %>
      </span>
    </a>
    """
  end

  @impl true
  def handle_event("execute_job", %{"process-id" => _process_id}, socket) do
    IO.puts("Handling execute job event")

    safe_steps =
      socket.assigns.object.steps
      |> Enum.sort(&(&1.order <= &2.order))
      |> Enum.map(&safe_step/1)

    payload =  %{
      id: socket.assigns.object.id,
      element_id: socket.assigns.id,
      status: "not_started",
      steps: safe_steps,
      active_annotations: []
    }

    socket = push_event(socket, "message", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_status", %{ "status" => status } = payload, socket) do

    socket =
      socket
      |> assign(:status, String.to_atom(status))
      |> assign(:error, payload["error"])

    {:noreply, socket}
  end

  defp safe_step(step) do
    IO.inspect(step)
    %{
      type: String.downcase(step.step_type.name) |> String.replace(" ", "_"),
      element_id: "step-" <> Integer.to_string(step.id) <> "-runner",
      id: step.id,
      element: safe_element(step.element),
      annotation: safe_annotation(step.annotation),
      args: %{
        order: step.order,
        url: step.url,
        width: step.width,
        height: step.height,
        text: step.text,
      }
    }
  end

  def safe_element(element = %UserDocs.Web.Element{}) do
    %{
      name: element.name,
      strategy: element.strategy,
      selector: element.selector
    }
  end
  def safe_element(_) do
    safe_element(%UserDocs.Web.Element{})
  end

  def safe_annotation(annotation = %UserDocs.Web.Annotation{}) do
    %{
      annotation_type: safe_annotation_type(annotation.annotation_type),
      label: annotation.label,
      x_orientation: annotation.x_orientation,
      y_orientation: annotation.y_orientation,
      size: annotation.size,
      color: annotation.color,
      thickness: annotation.thickness,
      x_offset: annotation.x_offset,
      y_offset: annotation.y_offset,
      font_size: annotation.font_size
    }
  end
  def safe_annotation(_) do
    safe_annotation(%UserDocs.Web.Annotation{
        annotation_type: safe_annotation_type(nil)
    })
  end

  def safe_annotation_type(annotation_type = %UserDocs.Web.AnnotationType{}) do
    IO.inspect(annotation_type)
    name = try do
      String.downcase(annotation_type.name)
    rescue
      _ -> ""
    end
    %{
      name: name,
      args: annotation_type.args
    }
  end
  def safe_annotation_type(_) do
    safe_annotation_type(%UserDocs.Web.AnnotationType{})
  end

  def maybe_strategy(nil), do: ""
  def maybe_strategy(element), do: element.strategy

  def maybe_selector(nil), do: ""
  def maybe_selector(element), do: element.selector

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:status, :ok)
      |> assign(:error, "")

    {:ok, socket}
  end
end
