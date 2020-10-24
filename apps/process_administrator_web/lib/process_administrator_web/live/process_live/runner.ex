defmodule ProcessAdministratorWeb.ProcessLive.Runner do
  use ProcessAdministratorWeb, :live_component

  alias UserDocs.Automation.Runner

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item"
      id="<%= @id %>"
      phx-click="execute_job"
      phx-value-process-id="<%= @process.id %>"
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
  def handle_event("execute_job", %{"process-id" => process_id}, socket) do
    _log_string = "Executing process " <> process_id
    IO.puts(_log_string)

    payload =  %{
      type: "process",
      payload: %{
        process: Runner.parse(socket.assigns.process),
        element_id: socket.assigns.id,
        status: "not_started",
        active_annotations: []
      }
    }

    {:noreply, push_event(socket, "message", payload)}
  end

  @impl true
  def handle_event("update_status", %{ "status" => status } = payload, socket) do

    socket =
      socket
      |> assign(:status, String.to_atom(status))
      |> assign(:error, payload["error"])

    {:noreply, socket}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:status, :ok)
      |> assign(:error, "")

    {:ok, socket}
  end
end
