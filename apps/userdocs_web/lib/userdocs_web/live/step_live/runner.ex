defmodule UserDocsWeb.StepLive.Runner do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocs.Automation.Runner

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item"
      id="<%= @id %>"
      phx-click="execute_step"
      phx-value-step-id="<%= @step.id %>"
      phx-hook="executeStep"
      phx-target="<%= @myself.cid %>"
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

  def handle_event("execute_step", %{"step-id" => step_id}, socket) do
    _log_string = "Executing step " <> step_id
    IO.puts(_log_string)

    payload =  %{
      type: "step",
      payload: %{
        process: %{
          steps: [ Runner.parse(socket.assigns.step) ],
        },
        element_id: socket.assigns.id,
        status: "not_started",
        active_annotations: []
      }
    }

    {:noreply, push_event(socket, "message", payload)}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:status, :ok)
      |> assign(:error, "")

    {:ok, socket}
  end


  @impl true
  def handle_event("update_job_status", %{ "status" => "failed" } = payload, socket) do

    socket =
      socket
      |> assign(:status, :failed)
      |> assign(:error, payload["error"])

    {:noreply, socket}
  end
  def handle_event("update_job_status", %{ "status" => "ok" }, socket) do

    socket =
      socket
      |> assign(:status, :ok)

    {:noreply, socket}
  end
  def handle_event("update_job_status", %{ "status" => "running" }, socket) do

    socket =
      socket
      |> assign(:status, :running)

    {:noreply, socket}
  end
  def handle_event("update_job_status", %{ "status" => "complete" }, socket) do

    socket =
      socket
      |> assign(:status, :complete)

    {:noreply, socket}
  end
end
