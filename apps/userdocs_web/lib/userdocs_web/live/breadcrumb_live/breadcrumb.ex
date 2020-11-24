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
          <li class="is-active"><a href="#" aria-current="page"><%= @version_name %></a></li>
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
    team = Users.get_team!(assigns.current_team_id, assigns, Defaults.state_opts())
    project = Projects.get_project!(assigns.current_project_id, assigns, Defaults.state_opts())
    version = Projects.get_version!(assigns.current_version_id, assigns, Defaults.state_opts())
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:team_name, team.name)
      |> assign(:project_name, project.name)
      |> assign(:version_name, version.name)
    }
  end
end
