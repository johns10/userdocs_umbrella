defmodule UserDocsWeb.StepLive.Queuer do
  @moduledoc """
    The queuer component, which is used to add steps to a job
  """
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  @impl true
  def render(assigns) do
    ~L"""
    <a class="navbar-item"
      id="<%= @id %>"
      phx-click="create-job-step"
      phx-value-step-id="<%= @step.id %>"
      phx-target="#automation-manager"
    >
      <span class="icon">
        <%= content_tag(:i, "", [class: "fa fa-plus", aria_hidden: "true"]) %>
      </span>
    </a>
    """
  end
end
