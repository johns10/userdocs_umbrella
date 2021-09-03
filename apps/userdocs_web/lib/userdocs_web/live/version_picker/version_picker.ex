defmodule UserDocsWeb.ProjectPicker do
  @moduledoc false
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  use UserdocsWeb.LiveViewPowHelper

  def dropdown_trigger(assigns, name, _highlight, do: block) do
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
      <a class="navbar-link"><%= @selected_project_name %></a>
      <div class="navbar-dropdown">
        <%= for team_user <- @current_user.team_users do %>
          <%= dropdown_trigger(assigns, team_user.team.name, team_user.team.id == @current_user.selected_team_id) do %>
            <div class="dropdown-menu" role="menu">
              <div class="dropdown-content" >
                <%= for project <- team_user.team.projects do %>
                  <a href="#"
                    class="<%= is_active(@current_user.selected_project_id, project.id) %>"
                    id="project-picker-<%= project.id %>"
                    phx-click="select-project"
                    phx-value-project-id="<%= project.id %>"
                    phx-value-team-id="<%= team_user.team.id %>"
                  ><%= project.name %></a>
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
    current_project_name =
      case assigns.current_project do
        %UserDocs.Projects.Project{name: nil} = _project -> "None Selected"
        %UserDocs.Projects.Project{name: name} = _project -> name
        _ -> "None Selected"
      end

    selected_project_name =
      case assigns.current_user do
        %UserDocs.Users.User{ selected_project: %UserDocs.Projects.Project{ name: name }} -> name
        _ -> "None Selected"
      end
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:current_project_name, current_project_name)
      |> assign(:selected_project_name, selected_project_name)
    }
  end

  def is_active(id1, id2) do
    case id1 == id2 do
      true -> "dropdown-item is-active"
      false -> "dropdown-item"
    end
  end
end
