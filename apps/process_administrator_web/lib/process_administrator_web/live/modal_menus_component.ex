defmodule ProcessAdministratorWeb.ModalMenus do
  use ProcessAdministratorWeb, :live_component
  use Phoenix.HTML


  alias ProcessAdministratorWeb.LiveHelpers
  alias ProcessAdministratorWeb.VersionLive.FormComponent, as: VersionForm
  alias ProcessAdministratorWeb.ProjectLive.FormComponent, as: ProjectForm
  alias ProcessAdministratorWeb.ProcessLive.FormComponent, as: ProcessForm

  @impl true
  def render(assigns) do
    ~L"""
      <div id="<%= @id %>">
        <%= if @action in [:new, :edit] do %>
          <%=
            case @type do
              :version ->
                LiveHelpers.live_modal @socket, VersionForm,
                  id: @object.id || :new,
                  title: @title,
                  action: @action,
                  version: @object,
                  parent_id: @parent.id,
                  return_to: Routes.automation_index_path(@socket, :index),
                  select_lists: %{
                    strategies: @select_lists.strategies,
                    projects: @select_lists.projects
                  }
              :project ->
                LiveHelpers.live_modal @socket, ProjectForm,
                  id: @object.id || :new,
                  title: @title,
                  action: @action,
                  project: @object,
                  parent_id: @parent.id,
                  select_lists: %{
                    teams: @select_lists.teams,
                  }
              :process ->
                LiveHelpers.live_modal @socket, ProcessForm,
                  id: @object.id || :new,
                  title: @title,
                  action: @action,
                  process: @object,
                  parent_id: @parent.id,
                  select_lists: %{
                    versions: @select_lists.versions,
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
