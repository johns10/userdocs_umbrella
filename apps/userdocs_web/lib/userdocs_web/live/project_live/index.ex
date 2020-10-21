defmodule UserDocsWeb.ProjectLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Projects
  alias UserDocs.Projects.Project
  use UserdocsWeb.LiveViewPowHelper

  @impl true
  def mount(_params, session, socket) do
    { :ok,
    socket
    |> assign(:projects, list_projects())
    |> maybe_assign_current_user(session)}
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
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, assign(socket, :projects, list_projects())}
  end

  defp list_projects do
    Projects.list_projects()
  end
end
