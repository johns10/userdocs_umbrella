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
    <style>
      /* since nested groupes are not supported we have to use
         regular css for the nested dropdowns
      */
      li>ul                 { transform: translatex(100%) scale(0) }
      li:hover>ul           { transform: translatex(101%) scale(1) }
      li > button svg       { transform: rotate(-90deg) }
      li:hover > button svg { transform: rotate(-270deg) }
      .selected::before     { content: "\f005"; font-family: FontAwesome; }

      /* Below styles fake what can be achieved with the tailwind config
         you need to add the group-hover variant to scale and define your custom
         min width style.
         See https://codesandbox.io/s/tailwindcss-multilevel-dropdown-y91j7?file=/index.html
         for implementation with config file
      */
      .group:hover .group-hover\:scale-100 { transform: scale(1) }
      .group:hover .group-hover\:-rotate-180 { transform: rotate(180deg) }
      .scale-0 { transform: scale(0) }
      .min-w-32 { min-width: 8rem }
    </style>
    <div class="group inline-block">
      <button class="flex-1 btn btn-ghost bnt-sm">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
        </svg>
        <%= @selected_project_name %>
      </button>
      <ul class="shadow p-2 bg-base-100 rounded-box transform scale-0 group-hover:scale-100 absolute transition duration-150 ease-in-out origin-top min-w-32">
        <%= for team_user <- @current_user.team_users do %>
          <li class="rounded-sm relative px-3 py-1 hover:bg-gray-400 flex items-center outline-none focus:outline-none min-w-32">
            <span class="pr-1 flex-1 text-black"><%= team_user.team.name %></span>
            <span class="mr-auto">
              <svg class="fill-current h-4 w-4 transition duration-150 ease-in-out" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/>
              </svg>
            </span>
            <ul class="shadow p-2 bg-base-100 rounded-box transform scale-0 absolute top-0 right-0 transition duration-150 ease-in-out origin-top-left min-w-32">
              <%= for project <- team_user.team.projects do %>
                <li class="rounded-sm relative px-3 py-1 hover:bg-gray-100">
                  <button
                    class="w-full text-left flex items-center outline-none focus:outline-none"
                    id="project-picker-<%= project.id %>"
                    phx-click="select-project"
                    phx-value-project-id="<%= project.id %>"
                    phx-value-team-id="<%= team_user.team.id %>"
                  >
                    <span class="pr-1 flex-1 text-black whitespace-nowrap <%= is_active(@current_user.selected_project_id, project.id) %>">
                      <%= project.name %>
                    </span>
                  </button>
                </li>
              <% end %>
            </ul>
          </li>
        <% end %>
      </ul>
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
      true -> "selected"
      false -> ""
    end
  end
end
