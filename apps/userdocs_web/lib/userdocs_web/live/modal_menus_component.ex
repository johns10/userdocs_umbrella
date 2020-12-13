defmodule UserDocsWeb.ModalMenus do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  alias UserDocsWeb.ModalMenus
  alias UserDocsWeb.LiveHelpers

  alias ProcessAdministratorWeb.VersionLive.FormComponent, as: VersionForm
  alias ProcessAdministratorWeb.ProjectLive.FormComponent, as: ProjectForm
  alias ProcessAdministratorWeb.ProcessLive.FormComponent, as: ProcessForm

  alias UserDocsWeb.ContentLive.FormComponent, as: ContentForm
  alias UserDocsWeb.DocumentLive.FormComponent, as: DocumentForm
  alias UserDocsWeb.DocumentVersionLive.FormComponent, as: DocumentVersionForm
  alias UserDocsWeb.DocubitLive.FormComponent, as: DocubitForm

  alias UserDocs.Project.Messages, as: ProjectMessage
  alias UserDocs.Version.Messages, as: VersionMessage
  alias UserDocs.Process.Messages, as: ProcessMessage
  alias UserDocs.Document.Messages, as: DocumentMessage
  alias UserDocs.DocumentVersion.Messages, as: DocumentVersionMessage
  alias UserDocs.Docubit.Messages, as: DocubitMessage
  alias UserDocs.Documents.Content.Messages, as: ContentMessage

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
              :document ->
                LiveHelpers.live_modal @socket, DocumentForm,
                  id: @object.id || :new,
                  title: @title,
                  action: @action,
                  document: @object,
                  team_id: @team_id,
                  channel: @channel,
                  select_lists: %{
                    projects: @select_lists.projects,
                  }
              :document_version ->
                LiveHelpers.live_modal @socket, DocumentVersionForm,
                  id: @object.id || :new,
                  title: @title,
                  action: @action,
                  document_version: @object,
                  document_id: @document_id,
                  version_id: @version_id,
                  channel: @channel,
                  select_lists: %{
                    documents: @select_lists.documents,
                    versions: @select_lists.versions
                  }
                :docubit ->
                  LiveHelpers.live_modal @socket, DocubitForm,
                    id: :new,
                    title: @title,
                    action: @action,
                    docubit: @object,
                    document_version_id: @document_version_id,
                    docubit_id: @docubit_id,
                    channel: @channel,
                    select_lists: %{
                      allowed_children: @select_lists.allowed_children
                    }
                :content ->
                  LiveHelpers.live_modal @socket, ContentForm,
                  id: @object.id || :new,
                    title: @title,
                    action: @action,
                    content: @object,
                    team_id: @team_id,
                    version_id: @version_id,
                    channel: @channel,
                    select_lists: %{
                      teams: @select_lists.teams,
                      language_codes: @select_lists.language_codes
                    }
            end
          %>
        <% end %>
      </div>
    """
  end

  # TODO: Fix this
  def call_menu(message, socket) do
    Phoenix.LiveView.send_update(
      ModalMenus,
      id: "modal-menus",
      title: message.title,
      object: message.object,
      action: message.action,
      parent: Map.get(message, :parent, nil),
      parent_id: Map.get(message, :parent_id, nil),
      team_id: Map.get(message, :team_id, nil),
      document_id: Map.get(message, :document_id, nil),
      document_version_id: Map.get(message, :document_id, nil),
      docubit_id: Map.get(message, :docubit_id, nil),
      version_id: Map.get(message, :version_id, nil),
      type: message.type,
      select_lists: Map.get(message, :select_lists, nil),
      channel: Map.get(message, :channel, nil)
    )

    socket
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

  def new_document(socket, params) do
    {
      :noreply,
      DocumentMessage.new_modal_menu(socket, params)
      |> call_menu(socket)
    }
  end

  def edit_document(socket, params) do
    {
      :noreply,
      DocumentMessage.edit_modal_menu(socket, params)
      |> call_menu(socket)
    }
  end

  def new_document_version(socket, params) do
    {
      :noreply,
      DocumentVersionMessage.new_modal_menu(socket, params)
      |> call_menu(socket)
    }
  end

  def edit_document_version(socket, params) do
    {
      :noreply,
      DocumentVersionMessage.edit_modal_menu(socket, params)
      |> call_menu(socket)
    }
  end

  def new_docubit(socket, params) do
    {
      :noreply,
      DocubitMessage.new_modal_menu(socket, params)
      |> call_menu(socket)
    }
  end

  def edit_content(socket, params) do
    socket
    |> ContentMessage.edit_modal_menu(params)
    |> call_menu(socket)
  end

  def new_content(socket, params) do
    socket
    |> ContentMessage.new_modal_menu(params)
    |> call_menu(socket)
  end

  def close(socket) do
    Phoenix.LiveView.send_update(
      ModalMenus,
      id: "modal-menus",
      action: :show)
    socket
  end

end
