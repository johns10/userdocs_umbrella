defmodule UserDocsWeb.VersionLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Projects
  alias UserDocs.Web

  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.LiveHelpers

  @impl true
  def update(%{version: version} = assigns, socket) do
    changeset = Projects.change_version(version)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:strategies_select_options, strategies_select_options())
      |> project_select_options()
    }
  end

  @impl true
  def handle_event("validate", %{"version" => version_params}, socket) do
    changeset =
      socket.assigns.version
      |> Projects.change_version(version_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"version" => version_params}, socket) do
    save_version(socket, socket.assigns.action, version_params)
  end

  defp save_version(socket, :edit, version_params) do
    case Projects.update_version(socket.assigns.version, version_params) do
      {:ok, _version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Version updated successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_version(socket, :new, version_params) do
    case Projects.create_version(version_params) do
      {:ok, _version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Version created successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp strategies_select_options do
    Web.list_strategies()
    |> DomainHelpers.select_list_temp(:name, false)
  end

  defp project_select_options(socket) do
    { :ok, socket } =
      { :nok, socket }
      |> projects_assigns()
      |> projects_domain()
      |> projects_select_list()

    socket
  end

  defp projects_assigns({ :nok, socket = %{assigns: %{projects: projects}}}) do
    current_project =
      projects
      |> Enum.filter(fn(p)-> p.id == socket.assigns.version.project_id end)
      |> Enum.at(0)

    filtered_projects = Enum.filter(projects,
      fn(p) -> p.team_id == current_project.team_id end)
    { :ok, assign(socket, :projects, filtered_projects) }
  end
  defp projects_assigns({ :nok, socket }), do: { :nok, socket }

  defp projects_domain({ :ok, socket }), do: { :ok, socket }
  defp projects_domain({ :nok, socket }) do
    current_project = UserDocs.Projects.get_project!(socket.assigns.version.project_id)
    projects = UserDocs.Projects.list_projects(%{}, %{team_id: current_project.team_id})
    { :ok, assign(socket, :projects, projects) }
  end

  defp projects_select_list({ :ok, socket = %{assigns: %{projects: projects}} }) do
    projects_select_list =
      projects
      |> Enum.map(&{Map.get(&1, :name), &1.id})

    { :ok, assign(socket, :projects_select_list, projects_select_list)}
  end
  defp projects_select_list({ :ok, socket }),  do: { :ok, socket}
end
