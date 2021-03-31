defmodule UserDocsWeb.VersionPicker do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocsWeb.Defaults

  alias UserDocs.Users

  def dropdown_trigger(assigns, name, highlight, do: block) do
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

  def button_class(true), do: "button is-link"

  @impl true
  def render(assigns) do
    ~L"""
    <div class="navbar-item has-dropdown is-hoverable">
      <a class="navbar-link"><%= @selected_version_name %></a>
      <div class="navbar-dropdown">
        <%= for team_user <- @current_user.team_users do %>
          <%= dropdown_trigger(assigns, team_user.team.name, team_user.team.id == @current_user.selected_team_id) do %>
            <div class="dropdown-menu" role="menu">
              <div class="dropdown-content" >
                <%= for project <- team_user.team.projects do %>
                  <%= dropdown_trigger(assigns, project.name, project.id == @current_user.selected_project_id) do %>
                    <div class="dropdown-menu" role="menu">
                      <div class="dropdown-content">
                        <%= for version <- project.versions do %>
                          <a href="#"
                            class="<%= is_active(@current_user.selected_version_id, version.id) %>"
                            id="version-picker-<%= version.id %>"
                            phx-click="select-version"
                            phx-value-version-id="<%= version.id %>"
                            phx-value-project-id="<%= project.id %>"
                            phx-value-team-id="<%= team_user.team.id %>"
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
    current_version_name =
      case assigns.current_version do
        %UserDocs.Projects.Version{ name: nil } = version -> "None Selected"
        %UserDocs.Projects.Version{ name: name } = version -> name
        _ -> "None Selected"
      end

    selected_version_name =
      case assigns.current_user do
        %UserDocs.Users.User{ selected_version: %UserDocs.Projects.Version{ name: name }} -> name
        _ -> "None Selected"
      end

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:current_version_name, current_version_name)
      |> assign(:selected_version_name, selected_version_name)
    }
  end

  def is_active(id1, id2) do
    case id1 == id2 do
      true -> "dropdown-item is-active"
      false -> "dropdown-item"
    end
  end
end
