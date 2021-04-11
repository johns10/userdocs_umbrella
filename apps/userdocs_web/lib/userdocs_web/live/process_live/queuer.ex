defmodule UserDocsWeb.ProcessLive.Queuer do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation.Runner

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item"
      id="<%= @id %>"
      phx-click="add-process-instance"
      phx-value-process-id="<%= @process.id %>"
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
