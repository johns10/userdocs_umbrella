defmodule UserDocsWeb.AutomationLive.Index do
  require Logger

  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocsWeb.State

  alias UserDocsWeb.AutomationLive.Index.Select
  alias UserDocsWeb.SocketHelpers
  alias UserDocsWeb.Endpoint
  alias UserDocsWeb.DomainHelpers

  alias UserDocs.Web
  alias UserDocs.Web.Strategy
  alias UserDocs.Web.Element
  alias UserDocs.Web.Annotation
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocs.Documents.Content

  @impl true
  def mount(_params, session, socket) do
    Endpoint.subscribe("process")
    Endpoint.subscribe("page")
    Endpoint.subscribe("version_process")
    Endpoint.subscribe("step")
    Endpoint.subscribe("element")
    Endpoint.subscribe("annotation")
    Endpoint.subscribe("content_version")
    Endpoint.subscribe("content")

    strategies = strategies()

    strategies_select_options =
      strategies
      |> DomainHelpers.select_list_temp(:name, false)

    # Get Data from the Database
    Logger.debug("DB operations")
    socket = socket
    |> maybe_assign_current_user(session)
    |> assign(:title, "")
    |> assign(:form_type, nil)
    |> Select.assign_changeset(:current_user_changeset, :current_user, &Users.change_user/2, %User{})
    |> assign_team_users()
    |> assign_teams()
    |> Select.assign_function(:projects, &projects/1, :teams)
    |> Select.assign_function(:versions, &versions/1, :projects)
    |> Select.assign_function(:available_teams, &Select.available_teams/1)
    |> Select.handle_team_selection(nil)
    |> Select.handle_project_selection(nil)
    |> Select.handle_version_selection(nil)
    |> Select.assign_function(:select_lists, &select_lists/1)
    |> assign(:strategy, strategies)
    |> assign(:strategies_select_options, strategies_select_options)
    |> Select.assign_function(:current_strategy, &current_strategy/1, :current_version)
    |> assign(:transferred_strategy, %Strategy{})
    |> assign(:transferred_selector, "")
    |> send_extension_configuration()
    |> assign(SocketHelpers.automation_ui_socket())
    |> assign_version_details()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Projects.get_project!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_event("edit-version", _, socket) do
    {:noreply,
    socket
    |> assign(:current_version, socket.assigns.current_version)
    |> assign(:form_type, :version)
    |> assign(:live_action, :edit)
    |> assign(:title, "Edit Version")}
  end

  @impl true
  def handle_event("new-version", _, socket) do
    {:noreply,
    socket
    |> assign(:current_version, %Version{})
    |> assign(:form_type, :version)
    |> assign(:live_action, :new)
    |> assign(:title, "New Version")}
  end

  @impl true
  def handle_event("edit-project", _, socket) do
    {
      :noreply,
      socket
      |> assign(:current_project, socket.assigns.current_project)
      |> assign(:form_type, :project)
      |> assign(:live_action, :edit)
      |> assign(:title, "Edit Project")
    }
  end

  @impl true
  def handle_event("new-project", _, socket) do
    {
      :noreply,
      socket
      |> assign(:current_project, %Project{})
      |> assign(:form_type, :project)
      |> assign(:live_action, :new)
      |> assign(:title, "New Project")
    }
  end

  @impl true
  def handle_event("new-content", _, socket) do
    {
      :noreply,
      socket
      |> assign(:current_content, %Content{})
      |> assign(:form_type, :content)
      |> assign(:live_action, :new)
      |> assign(:title, "New Content")
    }
  end

  @impl true
  def handle_event("new-element", %{ "page-id" => page_id }, socket) do
    IO.puts("Automation Live creating new element")
    {
      :noreply,
      socket
      |> assign(:current_element, %Element{})
      |> assign(:current_page, %{ id: String.to_integer(page_id) })
      |> assign(:form_type, :element)
      |> assign(:live_action, :new)
      |> assign(:title, "New Element")
    }
  end

  @impl true
  def handle_event("new-annotation", payload = %{ "page-id" => page_id, "element-id" => element_id }, socket) do
    IO.puts("Automation Live creating new annotation for element #{element_id}")

    element =
      socket.assigns.select_lists.available_elements
      |> Enum.filter(fn(e) -> e.id == String.to_integer(element_id) end)
      |> Enum.at(0)

    {
      :noreply,
      socket
      |> assign(:current_annotation, %Annotation{})
      |> assign(:current_element, element)
      |> assign(:current_page, %{ id: String.to_integer(page_id) })
      |> assign(:form_type, :annotation)
      |> assign(:live_action, :new)
      |> assign(:title, "New Annotation")
    }
  end

  @impl true
  def handle_info({:transfer_selector, %{"selector" => selector, "strategy" => %{"id" => id}}}, socket) do
    IO.puts("Handling Selector Transfer")

    strategy =
      socket.assigns.strategy
      |> Enum.filter(fn(s) -> s.id == id end)
      |> Enum.at(0)

    IO.puts("Updating transferred selector to #{strategy.id}, #{strategy.name}")

    {
      :noreply,
      socket
      |> assign(:transferred_strategy, strategy)
      |> assign(:transferred_selector, selector)
    }
  end

  # TODO: Must implement either updating the state tree/components
  def handle_info(%{topic: _topic, event: _event, payload: _payload}, socket) do
    socket =
      socket
      |> Select.assign_function(:select_lists, &select_lists/1)
      |> assign(:version, Automation.details(socket.assigns.current_version.id))
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, assign(socket, :projects, list_projects())}
  end

  def handle_event("update_selected_team", %{"user" => %{"default_team_id" => team_id}}, socket) do
    socket =
      socket
      |> Select.handle_team_selection(String.to_integer(team_id))
      |> Select.handle_project_selection(nil)
      |> Select.handle_version_selection(nil)
      |> assign_version_details()

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_selected_project", %{"team" => %{"default_project_id" => project_id}}, socket) do
    socket =
      socket
      |> Select.handle_project_selection(String.to_integer(project_id))
      |> Select.handle_version_selection(nil)
      |> assign_version_details()

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_selected_version", %{"project" => %{"default_version_id" => version_id}}, socket) do
    socket =
      socket
      |> Select.handle_version_selection(String.to_integer(version_id))
      |> assign_version_details()

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_current_strategy", %{"current_strategy" => %{ "strategy_id" => id }}, socket) do
    strategy =
      socket.assigns.strategy
      |> Enum.filter(fn(s) -> s.id == String.to_integer(id) end)
      |> Enum.at(0)

    IO.puts("Updating Current Strategy to #{strategy.name}")

    message = %{
      type: "configuration",
      payload: %{
        strategy: Strategy.safe(strategy)
      }
    }

    {
      :noreply,
      socket
      |> push_event("configure", message)
      |> assign(:current_strategy, strategy)
    }
  end

  defp strategies do
    Logger.debug("AutomationLive.Index retreiving strategies from database")
    Web.list_strategies()
  end

  defp current_strategy(current_version) do
    IO.puts("Current Strategy")
    current_version.strategy
  end

  defp list_projects do
    Projects.list_projects()
  end

  defp assign_team_users(socket) do
    assign(socket, :team_users, team_users(socket))
  end
  defp team_users(socket) do
    case socket.assigns.current_user do
      nil -> raise("User not found, or not logged in")
      _ -> Users.list_team_users(%{}, %{user_id: socket.assigns.current_user.id})
    end
  end

  defp assign_teams(socket) do
    assign(socket, :teams, teams(socket))
  end
  defp teams(socket) do
    team_ids = Enum.map(socket.assigns.team_users, fn(t) -> t.team_id end)
    Users.list_teams(%{}, %{ids: team_ids})
  end

  defp projects(nil), do: []
  defp projects(teams) do
    _team_ids = Enum.map(teams, fn(t) -> t.id end)
    UserDocs.Projects.list_projects()
  end

  defp versions(nil), do: []
  defp versions(projects) do
    _project_ids = Enum.map(projects, fn(p) -> p.id end)
    UserDocs.Projects.list_versions(%{ strategy: true })
  end

  defp assign_version_details(socket) do
    assign(socket, :version, version_details(socket.assigns.current_version_id))
  end
  defp version_details(nil), do: %Version{}
  defp version_details(version_id), do: Automation.details(version_id)

  defp send_extension_configuration(socket) do
    message = %{
      type: "configuration",
      payload: %{
        strategy: Strategy.safe(socket.assigns.current_strategy)
      }
    }

    IO.puts("Sending Extension Configuration")

    socket
    |> push_event("configure", message)
  end

  defp select_lists(%{ assigns: %{ current_version: version, current_team: team}}) do
    %{}
    |> State.update(version.id, team.id)
  end
end
