defmodule UserDocsWeb.ModalMenus do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  alias UserDocsWeb.LiveHelpers

  alias UserDocsWeb.VersionLive.FormComponent, as: VersionForm
  alias UserDocsWeb.ProjectLive.FormComponent, as: ProjectForm
  alias UserDocsWeb.ProcessLive.FormComponent, as: ProcessForm
  alias UserDocsWeb.StepLive.FormComponent, as: StepForm

  alias UserDocs.Project.Messages, as: ProjectMessage
  alias UserDocs.Version.Messages, as: VersionMessage
  alias UserDocs.Process.Messages, as: ProcessMessage
  alias UserDocs.Automation.Step.Messages, as: StepMessage
  alias UserDocs.Docubit.Messages, as: DocubitMessage
  alias UserDocs.Users.User.Messages, as: UserMessage

  @impl true
  def render(assigns) do
    ~L"""
      <div id="<%= @id %>">
        <%= if @form_data.action in [:new, :edit] do %>
          <%=
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
                :step ->
                  LiveHelpers.live_modal @socket, StepForm,
                  id: @form_data.object.id || :new,
                    title: @form_data.title,
                    action: @form_data.action,
                    step: @form_data.object,
                    parent_id: @form_data.parent_id,
                    parent: @form_data.parent,
                    state_opts: @form_data.state_opts,
                    select_lists: %{
                      processes: @form_data.select_lists.processes,
                      step_types: @form_data.select_lists.step_types
                    },
                    data: %{
                      step_types: @form_data.data.step_types,
                      annotation_types: @form_data.data.annotation_types
                    }
            end
          %>
        <% end %>
      </div>
    """
  end

  # TODO: Fix this
  def call_menu(message, socket) do
    form_data = %{
      title: message.title,
      object: message.object,
      action: message.action,
      parent: Map.get(message, :parent, nil),
      parent_id: Map.get(message, :parent_id, nil),
      team_id: Map.get(message, :team_id, nil),
      docubit_id: Map.get(message, :docubit_id, nil),
      version_id: Map.get(message, :version_id, nil),
      type: message.type,
      select_lists: Map.get(message, :select_lists, nil),
      channel: Map.get(message, :channel, nil),
      state_opts: Map.get(message, :state_opts, nil),
      data: Map.get(message, :data, nil)
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

  def new_step(socket, params) do
    {
      :noreply,
      StepMessage.new_modal_menu(socket, params)
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
      ProjectMessage.new_modal_menu(socket)
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

  def edit_docubit(socket, params) do
    {
      :noreply,
      DocubitMessage.edit_modal_menu(socket, params)
      |> call_menu(socket)
    }
  end

  def edit_user(socket, params) do
    socket
    |> UserMessage.edit_modal_menu(params)
    |> call_menu(socket)
  end

  def close(socket) do
    assign(socket, :form_data, Map.put(socket.assigns.form_data, :action, :show))
  end

end
