defmodule UserDocsWeb.StepsLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card">
      <header class="card-header">
        <p class="card-header-title">
          <%= @object.name %>
        </p>
        <a href="#" class="card-header-icon" aria-label="more options">
          <span class="icon" phx-click="expand" phx-target="<%= @myself %>">
            <i class="fa fa-angle-down" aria-hidden="true"></i>
          </span>
        </a>
      </header>
      <div class="card-content <%= Layout.is_hidden?(assigns) %>">
        <div class="content">
          <ul>
            <li>
              <strong>Name:</strong>
              <%= @object.name %>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
