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
        <%= IO.puts("Rendering form"); "" %>
        <%= if @form_data.action in [:new, :edit] do %>
          <%=
            IO.puts("Running form code")
            case @form_data.type do
              :version ->
                LiveHelpers.live_modal @socket, VersionForm,
                  id: @form_data.object.id || :new,
                  title: @form_data.title,
                  action: @form_data.action,
                  version: @form_data.object,
                  parent_id: @form_data.parent.id,
                  select_lists: %{
                    strategies: @form_data.select_lists.strategies,
                    projects: @form_data.select_lists.projects
                  }
              :project ->
                LiveHelpers.live_modal @socket, ProjectForm,
                  id: @form_data.object.id || :new,
                  title: @form_data.title,
                  action: @form_data.action,
                  project: @form_data.object,
                  parent_id: @form_data.parent.id,
                  select_lists: %{
                    teams: @form_data.select_lists.teams,
                  }
              :process ->
                LiveHelpers.live_modal @socket, ProcessForm,
                  id: @form_data.object.id || :new,
                  process: @form_data.object,
                  title: @form_data.title,
                  action: @form_data.action,
                  parent_id: @form_data.version_id,
                  select_lists: %{
                    versions: @form_data.select_lists.versions,
                  }
              :document ->
                LiveHelpers.live_modal @socket, DocumentForm,
                  id: @form_data.object.id || :new,
                  title: @form_data.title,
                  action: @form_data.action,
                  document: @form_data.object,
                  team_id: @form_data.team_id,
                  channel: @form_data.channel,
                  select_lists: %{
                    projects: @form_data.select_lists.projects,
                  }
              :document_version ->
                LiveHelpers.live_modal @socket, DocumentVersionForm,
                  id: @form_data.object.id || :new,
                  title: @form_data.title,
                  action: @form_data.action,
                  document_version: @form_data.object,
                  document_id: @form_data.document_id,
                  version_id: @form_data.version_id,
                  channel: @form_data.channel,
                  select_lists: %{
                    documents: @form_data.select_lists.documents,
                    versions: @form_data.select_lists.versions
                  }
                :docubit ->
                  LiveHelpers.live_modal @socket, DocubitForm,
                    id: @form_data.object.id || :new,
                    title: @form_data.title,
                    action: @form_data.action,
                    docubit: @form_data.object,
                    document_version_id: @form_data.document_version_id,
                    docubit_id: @form_data.docubit_id,
                    channel: @form_data.channel
                :content ->
                  LiveHelpers.live_modal @socket, ContentForm,
                  id: @form_data.object.id || :new,
                    title: @form_data.title,
                    action: @form_data.action,
                    content: @form_data.object,
                    team_id: @form_data.team_id,
                    version_id: @form_data.version_id,
                    channel: @form_data.channel,
                    select_lists: %{
                      teams: @form_data.select_lists.teams,
                      versions: @form_data.select_lists.versions,
                      language_codes: @form_data.select_lists.language_codes,
                      content: @form_data.select_lists.content
                    }
            end
          %>
        <% end %>
      </div>
    """
  end

  # TODO: Fix this
  def call_menu(message, socket) do
    IO.puts("Assigning form data")
    form_data = %{
      title: message.title,
      object: message.object,
      action: message.action,
      parent: Map.get(message, :parent, nil),
      parent_id: Map.get(message, :parent_id, nil),
      team_id: Map.get(message, :team_id, nil),
      document_id: Map.get(message, :document_id, nil),
      document_version_id: Map.get(message, :document_id, nil), # TODO: Is this bug?
      docubit_id: Map.get(message, :docubit_id, nil),
      version_id: Map.get(message, :version_id, nil),
      type: message.type,
      select_lists: Map.get(message, :select_lists, nil),
      channel: Map.get(message, :channel, nil)
    }
    assign(socket, :form_data, form_data)
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

  def new_process(socket, params) do
    {
      :noreply,
      ProcessMessage.new_modal_menu(socket, params)
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

  def edit_docubit(socket, params) do
    {
      :noreply,
      DocubitMessage.edit_modal_menu(socket, params)
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
    assign(socket, :form_data, Map.put(socket.assigns.form_data, :action, :show))
  end

end
