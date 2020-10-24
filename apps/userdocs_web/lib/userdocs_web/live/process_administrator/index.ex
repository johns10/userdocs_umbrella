defmodule UserDocsWeb.ProcessAdministratorLive.Index do
  @behaviour Gettext.Plural
  require Logger

  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocsWeb.ProcessAdministratorLive.ID
  alias UserDocsWeb.ProcessAdministratorLive.ProcessLive
  alias UserDocsWeb.ProcessAdministratorLive.StepLive
  alias UserDocsWeb.ProcessAdministratorLive.LiveHelpers

  alias UserDocsWeb.State

  alias UserDocsWeb.Endpoint
  alias UserDocsWeb.DomainHelpers

  alias UserDocs.Automation.Step
  alias UserDocs.Web
  alias UserDocs.Web.Strategy
  alias UserDocs.Web.Element
  alias UserDocs.Web.Annotation
  alias UserDocs.Projects.Version
  alias UserDocs.Automation
  alias UserDocs.Projects.Select
  alias UserDocs.Projects.Version
  alias UserDocs.Projects.Project
  alias UserDocs.Documents
  alias UserDocs.Documents.Content

  alias UserDocsWeb.State

  @impl true
  def mount(_params, session, socket) do
    Endpoint.subscribe("process")
    Endpoint.subscribe("page")
    Endpoint.subscribe("process")
    Endpoint.subscribe("step")
    Endpoint.subscribe("element")
    Endpoint.subscribe("annotation")
    Endpoint.subscribe("content")

    # Get Data from the Database
    Logger.debug("DB operations")
    socket =
      socket
      |> validate_logged_in(session)
      |> initialize()

    {:ok, socket}
  end

  def validate_logged_in(socket, session) do
    try do
      case maybe_assign_current_user(socket, session) do
        %{ assigns: %{ current_user: nil }} ->
          socket
          |> assign(:auth_state, :not_logged_in)
          |> assign(:changeset, UserDocs.Users.change_user(%UserDocs.Users.User{}))
        %{ assigns: %{ current_user: _ }} ->
          socket
          |> maybe_assign_current_user(session)
          |> assign(:auth_state, :logged_in)
          |> (&(assign(&1, :changeset, UserDocs.Users.change_user(&1.assigns.current_user)))).()
        error ->
          IO.inspect(error)
          socket
      end
    rescue
      FunctionClauseError ->
        socket
        |> assign(:auth_state, :not_logged_in)
        |> assign(:changeset, UserDocs.Users.change_user(%UserDocs.Users.User{}))
    end
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    socket
    |> assign(:modal_action, :show)
    |> assign(:transferred_strategy, %Strategy{})
    |> assign(:transferred_selector, "")
    |> (&(  assign(&1, :annotation_types, State.annotation_types())                                         )).()
    |> (&(  assign(&1, :strategies,       State.strategies())                                               )).()
    |> (&(  assign(&1, :language_codes,   State.language_codes())                                           )).()
    |> (&(  assign(&1, :step_types,       State.step_types())                                               )).()
    |> (&(  assign(&1, :teams,            State.teams(&1.assigns.current_user.id))                          )).()
    |> (&(  assign(&1, :team_users,       State.team_users(&1.assigns.current_user.id))                     )).()
    |> (&(  assign(&1, :projects,         State.projects(&1.assigns.current_user.id))                       )).()
    |> (&(  assign(&1, :versions,         State.versions(&1.assigns.current_user.default_team_id))          )).()
    |> (&(  assign(&1, :content,          State.content(&1.assigns.current_user.default_team_id))           )).()
    |> (&(  assign(&1, :content_versions, State.content_versions(&1.assigns.current_user.default_team_id))  )).()
    |> (&(  State.apply_changes(&1, Select.initialize(&1.assigns))                                          )).()
    |> (&(  assign(&1, :current_strategy, &1.assigns.current_version.strategy)                              )).()
    |> (&(  assign(&1, :processes,        State.processes(&1.assigns.current_version.id))                   )).()
    |> (&(  assign(&1, :steps,            State.steps(&1.assigns.current_version.id))                       )).()
    |> (&(  assign(&1, :annotations,      State.annotations(&1.assigns.current_version.id))                 )).()
    |> (&(  assign(&1, :elements,         State.elements(&1.assigns.current_version.id))                    )).()
    |> (&(  assign(&1, :pages,            State.pages(&1.assigns.current_version.id))                       )).()
    |> (&(  assign(&1, :current_processes,Version.processes(&1.assigns.current_version.id, &1.assigns.processes))   )).()
    |> assign(:process_menu, [])
    |> State.report()
  end

  def initialize(%{ assigns: %{ auth_state: _ }} = socket) do
    Logger.debug("User not logged in")
    socket
  end

  def handle_info({:close_modal}, socket) do
    Phoenix.LiveView.send_update(
      UserDocsWeb.ProcessAdministratorLive.ModalMenus,
      id: "modal-menus",
      action: :show
    )
    { :noreply, socket }
  end
  def handle_info({_, message = %{ target: "ModalMenus"}}, socket) do
    {_, message} = Map.pop(message, :target)

    Phoenix.LiveView.send_update(
      UserDocsWeb.ProcessAdministratorLive.ModalMenus,
      id: "modal-menus",
      title: message.title,
      object: message.object,
      action: message.action,
      parent: message.parent,
      type: message.type,
      select_lists:
        Enum.reduce(
          message.select_list_constructors, %{},
          &construct_select_lists(socket, &1, &2)
        )
    )

    { :noreply, socket }
  end

  # This function finds the children of the thing in the submitted type
  # It is primarily used to construct the select lists in the menu
  # This should be moved somewhere else too.  It doesn't belong here
  # Refactor to use a domain function directly.  This is nasty.
  def construct_select_lists(
    socket, { target, module, function, object }, select_lists
  ) do
    options =
      Kernel.apply(
        module,
        function,
        [
          object,
          socket.assigns
        ]
      )

    select_options = DomainHelpers.select_list_temp(options, :name, false)

    Map.put(select_lists, target, select_options)
  end
  def construct_select_lists(socket, { target, key }, select_lists) do
    select_options =
      socket.assigns
      |> Map.get(key)
      |> DomainHelpers.select_list_temp(:name, false)

    Map.put(select_lists, target, select_options)
  end

  def handle_info({:update_current_version, changes}, socket) do
    current_processes =
      Version.processes(changes.current_version_id, socket.assigns.processes)

    {
      :noreply,
      socket
      |> assign(:current_processes, current_processes)
      |> State.apply_changes(changes)
    }
  end

  # TODO: Must implement either updating the state tree/components
  def handle_info(%{topic: topic, event: event, payload: payload}, socket) do
    Logger.debug("Handling a subscription on topic #{topic}, event #{event}")

    type =
      topic
      |> State.plural()
      |> String.to_atom()

    socket =
      State.apply_changes(
        socket,
        UserDocsWeb.State.update_object(socket.assigns, type, payload.id, payload)
      )

    {:noreply, socket}
  end
  # TODO: Must implement either updating the state tree/components
  def handle_info(%{topic: topic, event: event, payload: payload}, socket) do
    Logger.debug("Handling a subscription on topic #{topic}, event #{event}")
    args = String.split(topic, "::")
    type =
      args
      |> Enum.at(0)
      |> State.plural()
      |> String.to_atom

    field =
      try do
        args
        |> Enum.at(1)
        |> String.replace("-", "_")
        |> String.to_atom
      rescue
        _ -> "none"
      end

      Logger.debug("Updating type #{type}, field #{field}")
    socket =
      State.apply_changes(
        socket,
        UserDocsWeb.State.update_object_field(socket.assigns, type, payload.id, field, Map.get(payload, field))
      )

    {:noreply, socket}
  end

  def filter(socket, data_key, { filter_key, value }) do
    socket.assigns
    |> Map.get(data_key)
    |> Enum.filter(fn(o) -> Map.get(o, filter_key) == value end)
  end
  def filter(socket, data_key, {}) do
    socket.assigns
    |> Map.get(data_key)
  end

  def content_class([]), do: "content is-hidden"
  def content_class(_), do: "content"

  def handle_event("edit-content", _, socket) do
    IO.puts("Edit Content")
    message =
      base_message()
      |> content_message(socket)
      |> Map.put(:object, socket.assigns.annotation.content)
      |> Map.put(:action, :edit)
      |> Map.put(:title, "Edit Content")

    send(self(), {:edit_content, message})

    {:noreply, socket}
  end

  def handle_event("new-content", _, socket) do
    IO.puts("New Content")
    message =
      base_message()
      |> content_message(socket)
      |> Map.put(:object, %Content{})
      |> Map.put(:action, :new)
      |> Map.put(:title, "New Content")

    send(self(), {:new_content, message})

    {:noreply, socket}
  end

  def content_message(message, socket) do
    select_list_constructors = [
      {
        :teams,
        UserDocs.Users.User,
        :teams,
        socket.assigns.current_user
      }
    ]

    message
    |> Map.put(:type, :content)
    |> Map.put(:parent, %{id: 0})
    |> Map.put(:select_list_constructors, select_list_constructors)
  end

  def handle_event("edit-project", _, socket) do
    IO.puts("Edit Project")
    message =
      base_message()
      |> project_message(socket)
      |> Map.put(:object, socket.assigns.current_project)
      |> Map.put(:action, :edit)
      |> Map.put(:title, "Edit Project")

    send(self(), {:edit_project, message})

    {:noreply, socket}
  end

  def handle_event("new-project", _, socket) do
    IO.puts("New Project")
    message =
      base_message()
      |> project_message(socket)
      |> Map.put(:object, %Project{})
      |> Map.put(:action, :new)
      |> Map.put(:title, "New Project")

    send(self(), {:new_version, message})

    {:noreply, socket}
  end

  def project_message(message, socket) do
    select_list_constructors = [
      {
        :teams_select,
        UserDocs.Users.User,
        :teams,
        socket.assigns.current_user
      }
    ]

    message
    |> Map.put(:type, :project)
    |> Map.put(:parent, socket.assigns.current_team)
    |> Map.put(:select_list_constructors, select_list_constructors)
  end

  def handle_event("edit-version", _, socket) do
    IO.puts("Edit Versionzs")
    message =
      base_message()
      |> version_message(socket)
      |> Map.put(:object, socket.assigns.current_version)
      |> Map.put(:action, :edit)
      |> Map.put(:title, "Edit Version")

    send(self(), {:edit_version, message})

    {:noreply, socket}
  end

  def handle_event("new-version", _, socket) do
    IO.puts("New Versionzs")
    message =
      base_message()
      |> version_message(socket)
      |> Map.put(:object, %Version{})
      |> Map.put(:action, :new)
      |> Map.put(:title, "New Version")

    send(self(), {:new_version, message})

    {:noreply, socket}
  end

  def version_message(message, socket) do
    select_list_constructors = [
      {
        :projects_select,
        UserDocs.Users.Team,
        :projects,
        socket.assigns.current_team
      },
      {
        :strategies_select,
        :strategies
      }
    ]

    message
    |> Map.put(:type, :version)
    |> Map.put(:parent, socket.assigns.current_project)
    |> Map.put(:select_list_constructors, select_list_constructors)
  end

  def base_message() do
    %{
      target: "ModalMenus"
    }
  end

  def preload_step(step, state) do
    element =
      if step.element_id do
        element = Web.get_element!(step.element_id, %{ strategy: true }, %{}, state)
      end

    annotation =
      if step.annotation_id do
        annotation = Web.get_annotation!(step.annotation_id, %{}, %{}, state)

        annotation
        |> Map.put(:content, Documents.get_content!(annotation.content_id, %{}, %{}, state.content))
        |> Map.put(:annotation_type, Web.get_annotation_type!(annotation.annotation_type_id, %{}, %{}, state))
      end

    step
    |> Map.put(:page, Web.get_page!(state.pages, step.page_id))
    |> Map.put(:step_type, Automation.get_step_type!(state.step_types, step.step_type_id))
    |> Map.put(:annotation, annotation)
    |> Map.put(:element, element)
  end

  @impl true
  def handle_event("login", %{"user" => user_params}, socket) do
    IO.puts("Handling login")
    { :noreply, socket}
  end
end
