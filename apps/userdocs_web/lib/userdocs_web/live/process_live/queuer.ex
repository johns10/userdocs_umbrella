defmodule UserDocsWeb.ProcessLive.Queuer do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item"
      id="<%= @id %>"
      phx-click="create-job-process"
      phx-value-id="<%= @process.id %>"
      phx-value-name="<%= @process.name %>"
      phx-target="#automation-manager"
    >
      <span class="icon">
        <%= content_tag(:i, "", [class: "fa fa-plus", aria_hidden: "true"]) %>
      </span>
    </a>
    """
  end
end
