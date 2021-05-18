defmodule UserDocsWeb.StepLive.Runner do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

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
      phx-value-id="<%= @step.id %>"
      phx-target="#automation-manager"
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
end
