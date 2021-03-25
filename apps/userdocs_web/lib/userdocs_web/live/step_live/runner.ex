defmodule UserDocsWeb.StepLive.Runner do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocs.Automation.Runner

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:errors, [])
      |> assign(:status, :ok)
    }
  end

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item has-tooltip-left"
      id="<%= @id %>-runner"
      phx-click="execute_step"
      phx-value-step-id="<%= @step.id %>"
      phx-value-app="<%= @app_name %>"
      phx-hook="executeStep"
      phx-target="<%= @myself.cid %>"
      status="<%= @status %>"
      data-tooltip="<%= render_errors(@errors) %>"
    >
      <span class="icon">
        <%= case @status do
          :ok -> content_tag(:i, "", [class: "fa fa-play-circle", aria_hidden: "true"])
          :failed -> content_tag(:i, "", [class: "fa fa-times", aria_hidden: "true"])
          :started -> content_tag(:i, "", [class: "fa fa-spinner", aria_hidden: "true"])
          :complete -> content_tag(:i, "", [class: "fa fa-check", aria_hidden: "true"])
        end %>
      </span>
    </a>
    """
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
  def handle_event("execute_step", %{"step-id" => step_id} = payload, socket) do
    send self(), {:execute_step, %{ step_id: String.to_integer(step_id) }}
    { :noreply, socket }
  end
  def handle_event("execute_step", %{ "app" => "electron", "step-id" => step_id }, socket) do
    IO.inspect("Electron execute step #{step_id}")
    send self(), {:execute_step, %{ step_id: String.to_integer(step_id) }}
    { :noreply, socket }
  end
  def handle_event("update_step", %{ "status" => "failed", "errors" => errors } = payload, socket) do
    socket =
      socket
      |> assign(:status, :failed)
      |> assign(:errors, errors)

    {:noreply, socket}
  end
  def handle_event("update_step", %{ "status" => status }, socket) do
    {
      :noreply,
      socket
      |> assign(:status, String.to_atom(status))
    }
  end

  @impl true
  """
  def handle_event("execute_step", %{"step-id" => step_id} = payload, socket) do
    _log_string = "Executing step " <> step_id
    IO.puts(payload)

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
"""

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
end
