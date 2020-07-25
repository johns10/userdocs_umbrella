defmodule UserDocsWeb.StepLive.Runner do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item"
      id="<%= @id %>"
      phx-hook="executeStep"
      command="<%= @step_type_name %>"
      url="<%= @object.url %>"
      selector="<%= Map.get(@element, :selector) %>"
      strategy="<%= Map.get(@element, :strategy) %>"
      update-target="<%= @myself.cid %>"
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
