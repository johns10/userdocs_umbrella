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
      phx-hook="executeStep"
      phx-target="<%= @myself.cid %>"
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
  def handle_event("execute_step", %{"step-id" => step_id}, socket) do
    send self(), {:execute_step, %{ step_id: String.to_integer(step_id) }}
    { :noreply, socket }
  end
  def handle_event("execute_step", %{ "app" => "electron", "step-id" => step_id }, socket) do
    IO.inspect("Electron execute step #{step_id}")
    send self(), {:execute_step, %{ step_id: String.to_integer(step_id) }}
    { :noreply, socket }
  end
end
