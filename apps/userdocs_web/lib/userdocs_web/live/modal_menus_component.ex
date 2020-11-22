defmodule UserDocsWeb.ModalMenus do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  alias UserDocsWeb.ModalMenus
  alias UserDocsWeb.LiveHelpers
  alias ProcessAdministratorWeb.VersionLive.FormComponent, as: VersionForm
  alias ProcessAdministratorWeb.ProjectLive.FormComponent, as: ProjectForm
  alias ProcessAdministratorWeb.ProcessLive.FormComponent, as: ProcessForm
  alias UserDocs.Project.Messages, as: ProjectMessage
  alias UserDocs.Version.Messages, as: VersionMessage
  alias UserDocs.Process.Messages, as: ProcessMessage

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

  def new_process(socket) do
    {
      :noreply,
      ProcessMessage.new_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  def new_project(socket) do
    {
      :noreply,
      ProjectMessage.new_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  def edit_project(socket) do
    {
      :noreply,
      ProcessMessage.new_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  def edit_version(socket) do
    {
      :noreply,
      VersionMessage.edit_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  def new_version(socket) do
    {
      :noreply,
      VersionMessage.new_modal_menu(socket)
      |> call_menu(socket)
    }
  end

  def close(socket) do
    Phoenix.LiveView.send_update(
      ModalMenus,
      id: "modal-menus",
      action: :show)
    socket
  end

  def call_menu(message, socket) do
    {_, message} = Map.pop(message, :target)

    Phoenix.LiveView.send_update(
      ModalMenus,
      id: "modal-menus",
      title: message.title,
      object: message.object,
      action: message.action,
      parent: message.parent,
      type: message.type,
      select_lists: message.select_lists
    )

    socket
  end
end
