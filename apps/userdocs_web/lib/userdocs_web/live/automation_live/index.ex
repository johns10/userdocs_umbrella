defmodule UserDocsWeb.AutomationLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocsWeb.Layout
  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.SocketHelpers
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Projects.Project

  @impl true
  def mount(_params, session, socket) do
    socket = maybe_assign_current_user(socket, session)
    socket = assign(socket, SocketHelpers.automation_ui_socket())
    {:ok, assign(socket, :version, Automation.details(1))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def body(version) do
    project_options = DomainHelpers.build_select_list(Projects.list_projects())
    IO.inspect(project_options)
    [
      "test"
    ]
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
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, assign(socket, :projects, list_projects())}
  end

  def handle_event("test", _value, socket) do
    IO.puts("Test event")
    {:noreply, socket}
  end

  defp list_projects do
    Projects.list_projects()
  end
end
