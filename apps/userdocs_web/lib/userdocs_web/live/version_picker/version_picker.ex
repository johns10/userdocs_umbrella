defmodule UserDocsWeb.VersionPicker do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Automation

  def dropdown_trigger(assigns, name, do: block) do
    ~L"""
      <div class="nested navbar-item dropdown">
        <div class="dropdown-trigger">
          <button class="button" aria-haspopup="true" aria-controls="dropdown-menu">
            <span><%= name %></span>
            <span class="icon is-small">
              <i class="fa fa-angle-down" aria-hidden="true"></i>
            </span>
          </button>
        </div>
        <%= block %>
      </div>
    """
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="navbar-item has-dropdown is-hoverable">
      <a class="navbar-link">Version</a>
      <div class="navbar-dropdown">
        <%= for team <- @current_user.teams do %>
          <%= dropdown_trigger(assigns, team.name) do %>
            <div class="dropdown-menu" role="menu">
              <div class="dropdown-content">
                <%= for project <- team.projects do %>
                  <%= dropdown_trigger(assigns, project.name) do %>
                    <div class="dropdown-menu" role="menu">
                      <div class="dropdown-content">
                        <%= for version <- project.versions do %>
                          <a href="#"
                            class="dropdown-item"
                            phx-click="select_version"
                            phx-value-select-version="<%= version.id %>"
                          ><%= version.name %></a>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>

    """
  end

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:current_user, Automation.project_details(assigns.current_user, assigns))
    }
  end
end
