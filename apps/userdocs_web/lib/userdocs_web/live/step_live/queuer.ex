defmodule UserDocsWeb.StepLive.Queuer do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item"
      id="<%= @id %>"
      phx-click="add-step-instance"
      phx-value-step-id="<%= @step.id %>"
      phx-value-app="<%= @app_name %>"
      phx-target="#automation-manager"
    >
      <span class="icon">
        <%= content_tag(:i, "", [class: "fa fa-plus", aria_hidden: "true"]) %>
      </span>
    </a>
    """
  end
end
