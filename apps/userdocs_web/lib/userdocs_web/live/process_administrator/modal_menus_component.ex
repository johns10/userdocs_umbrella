defmodule UserDocsWeb.ProcessAdministratorLive.ModalMenus do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  alias UserDocsWeb.ProcessAdministratorLive.VersionLive
  alias UserDocsWeb.ProcessAdministratorLive.ProjectLive
  alias UserDocsWeb.ProcessAdministratorLive.ContentLive
  alias UserDocsWeb.ProcessAdministratorLive.ElementLive
  alias UserDocsWeb.ProcessAdministratorLive.AnnotationLive
  alias UserDocsWeb.ProcessAdministratorLive.LiveHelpers

  @impl true
  def render(assigns) do
    ~L"""
      <div id="<%= @id %>">
        <%= if @action in [:new, :edit] do %>
          <%=
            case @type do
              :version ->
                LiveHelpers.live_modal @socket, VersionLive.FormComponent,
                  id: @object.id || :new,
                  title: @title,
                  action: @action,
                  version: @object,
                  parent_id: @parent.id,
                  return_to: Routes.automation_index_path(@socket, :index),
                  select_lists: %{
                    strategies_select: @select_lists.strategies_select,
                    projects_select: @select_lists.projects_select
                  }
              :project ->
                LiveHelpers.live_modal @socket, ProjectLive.FormComponent,
                  id: @object.id || :new,
                  title: @title,
                  action: @action,
                  project: @object,
                  parent_id: @parent.id,
                  select_lists: %{
                    teams_select: @select_lists.teams_select,
                  }
              :content ->
                LiveHelpers.live_modal @socket, ContentLive.FormComponent,
                  id: @object.id || :new,
                  title: @title,
                  action: @action,
                  content: @object,
                  parent_id: @parent.id,
                  select_lists: %{
                    teams_select: @select_lists.teams,
                  }
              :element ->
                LiveHelpers.live_modal @socket, ElementLive.FormComponent,
                  id: @current_element.id || :new,
                  title: @title,
                  action: @action,
                  element: @current_element,
                  parent: @current_page,
                  current_user: @current_user,
                  select_lists: %{
                    teams: @data.teams
                  }
              :annotation ->
                LiveHelpers.live_modal @socket, AnnotationLive.FormComponent,
                  id: @current_annotation.id || :new,
                  title: @title,
                  action: @action,
                  annotation: @current_annotation,
                  parent: @current_page,
                  current_user: @current_user,
                  current_version: @current_version,
                  related_element_name: @current_element.name,
                  select_lists: %{
                    teams: @data.teams
                  }
            end
          %>
        <% end %>
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
    }
  end
end
