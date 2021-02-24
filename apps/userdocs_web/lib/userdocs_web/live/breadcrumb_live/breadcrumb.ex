defmodule UserDocsWeb.BreadCrumb do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocsWeb.Defaults

  alias UserDocs.Users
  alias UserDocs.Projects


  @impl true
  def render(assigns) do
    ~L"""
      <nav class="breadcrumb" aria-label="breadcrumbs">
        <ul>
          <li><a href="#"><%= @team_name %></a></li>
          <li><a href="#"><%= @project_name %></a></li>
          <%= for item <- @additional_items do %>
            <li><a href=<%= item.to %>><%= item.name %></a></li>
          <% end %>
          <li class="is-active">
            <%= live_patch to: @last_item.to, aria_current: "page" do %>
              <%= @last_item.name %>
            <% end %>
        </ul>
      </nav>
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
    opts = assigns.state_opts
    team = Users.get_team!(assigns.current_team_id, assigns, opts)
    project = Projects.get_project!(assigns.current_project_id, assigns, opts)
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:team_name, team.name)
      |> assign(:project_name, project.name)
    }
  end
end
