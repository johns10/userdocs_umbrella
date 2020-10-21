defmodule UserDocsWeb.ProjectLive.FormComponent do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.Layout
  alias UserDocsWeb.Form

  alias UserDocs.Users
  alias UserDocs.Projects

  @impl true
  def update(%{project: project} = assigns, socket) do
    changeset = Projects.change_project(project)
    IO.puts("Updating form")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> version_select_options()
     |> team_select_options()}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset =
      socket.assigns.project
      |> Projects.change_project(project_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Projects.update_project(socket.assigns.project, project_params) do
      {:ok, _project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Projects.create_project(project_params) do
      {:ok, _project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp team_select_options(socket) do
    { :ok, socket } =
      { :nok, socket }
      |> teams_assigns()
      |> teams_domain()
      |> teams_select_list()

    socket
  end

  defp teams_assigns({ :nok, socket = %{assigns: %{teams: teams}}}) do
    { :ok, assign(socket, :teams, teams) }
  end
  defp teams_assigns({ :nok, socket }), do: { :nok, socket }

  defp teams_domain({ :ok, socket }), do: { :ok, socket }
  defp teams_domain({ :nok, socket = %{assigns: %{current_user: current_user}}}) do
    { :ok,
    socket
    |> assign(:teams, UserDocs.Users.list_teams(%{}, %{ user_id: current_user.id })) }
  end

  defp teams_select_list({ :ok, socket = %{assigns: %{teams: teams}} }) do
    teams_select_list =
      teams
      |> Enum.map(&{Map.get(&1, :name), &1.id})

    { :ok, assign(socket, :teams_select_list, teams_select_list)}
  end
  defp teams_select_list({ :ok, socket }),  do: { :ok, socket}

  defp version_select_options(socket) do
    { :ok, socket } =
      { :nok, socket }
      |> versions_assigns()
      |> versions_domain()
      |> versions_select_list()

    socket
  end

  defp versions_assigns({ :nok, socket = %{assigns: %{project: project, versions: versions}}}) do
    filtered_versions = Enum.filter(versions,
      fn(v) -> v.project_id == project.id end)
    { :ok, assign(socket, :versions, filtered_versions) }
  end
  defp versions_assigns({ :nok, socket }), do: { :nok, socket }

  defp versions_domain({ :ok, socket }), do: { :ok, socket }
  defp versions_domain({ :nok, socket = %{assigns: %{project: project}}}) do
    versions = UserDocs.Projects.list_versions(%{}, %{ project_id: project.id })
    { :ok, assign(socket, :versions, versions) }
  end

  defp versions_select_list({ :ok, socket = %{assigns: %{versions: versions}} }) do
    versions_select_list =
      versions
      |> Enum.map(&{Map.get(&1, :name), &1.id})

    { :ok, assign(socket, :versions_select_list, versions_select_list)}
  end
  defp versions_select_list({ :ok, socket }),  do: { :ok, socket}
end
