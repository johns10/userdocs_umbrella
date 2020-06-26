defmodule UserDocsWeb.ProcessLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout
  alias UserDocsWeb.StepsLive

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card">
      <header class="card-header">
        <p class="card-header-title">
          <%= @object.name %>
        </p>
        <a class="card-header-icon" aria-label="more options">
          <span class="icon" phx-click="expand" phx-target="<%= @myself %>">
            <i class="fa fa-angle-down" aria-hidden="true"></i>
          </span>
        </a>
      </header>
      <div class="card-content <%= Layout.is_hidden?(assigns) %>">
        <div class="content">
          <%= for(step <- @object.steps) do %>
            <%= live_show(@socket, StepsLive.ShowComponent,
              id: "step-"
                <> Integer.to_string(step.id)
                <> "-show",
              object: step) %>
          <%= end %>
        </div>
      </div>
    </div>
    """
  end
end
