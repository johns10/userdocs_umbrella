defmodule ProcessAdministratorWeb.Index.Select do
  require Logger

  use UserDocsWeb, :live_view

  alias UserDocs.Users
  alias UserDocs.Projects

  alias UserDocs.Users.User
  alias UserDocs.Users.Team
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version

  def handle_team_selection(socket, team_id) do
    socket
    |> assign(:selected_team_id, team_id)
    |> assign_function(:current_team_id, &current_team_id/1)
    |> assign_function(:current_team, &current_team/1)
    |> assign_function(:available_projects, &available_projects/1)
    |> assign_changeset(:current_team_changeset, :current_team, &Users.change_team/2, %Team{})
  end

  @spec handle_project_selection(Phoenix.LiveView.Socket.t(), any) :: Phoenix.LiveView.Socket.t()
  def handle_project_selection(socket, project_id) do
    Logger.debug("Handling project selection for project id #{project_id}")
    socket
    |> assign(:selected_project_id, project_id)
    |> assign_function(:current_project_id, &current_project_id/1)
    |> assign_function(:current_project, &current_project/1)
    |> assign_function(:available_versions, &available_versions/1)
    |> assign_changeset(:current_project_changeset, :current_project, &Projects.change_project/2, %Project{})
  end

  @spec handle_team_selection(Phoenix.LiveView.Socket.t(), any) :: Phoenix.LiveView.Socket.t()
  def handle_version_selection(socket, version_id) do
    Logger.debug("Handling version selection ")
    socket
    |> assign(:selected_version_id, version_id)
    |> assign_function(:current_version_id, &current_version_id/1)
    |> assign_function(:current_version, &current_version/1)
    |> assign_changeset(:current_version_changeset, :current_version, &Projects.change_version/2, %Version{})
  end

  def available_teams(socket) do
    socket
    |> get_type(:teams)
    |> convert_to_select_list()
  end

  def assign_function(socket, target, function) do
    assign(socket, target, function.(socket))
  end

  def assign_function(socket, target, function, key) do
    assign(socket, target, function.(Map.get(socket.assigns, key)))
  end

  def assign_changeset(socket, target_key, source_key, change_function, fallback) do
    object =
      case object = Map.get(socket.assigns, source_key) do
        nil -> fallback
        _ -> object
      end
    assign(socket, target_key, change_function.(object, %{}))
  end

  def inspect_specific(socket, keys) do
    IO.inspect(Kernel.get_in(Map.get(socket, :assigns), keys))
    socket
  end

  defp current_team_id(socket) do
    IO.puts("getting current team id")
    { :ok, team_id } =
      { :nok, nil }
      |> maybe_value_from_socket(socket, :selected_team_id)
      |> maybe_current_user_default_team(socket.assigns)

    team_id
  end

  defp current_project_id(socket) do
    { :ok, project_id } =
      { :nok, nil }
      |> maybe_value_from_socket(socket, :selected_project_id)
      |> maybe_current_team_default_project_id(socket.assigns)

    project_id
  end

  defp current_version_id(socket) do
    { :ok, version_id } =
      { :nok, nil }
      |> maybe_value_from_assigns(socket.assigns, :selected_version_id)
      |> maybe_current_project_default_version(socket.assigns)
      |> maybe_first_version_in_assigns(socket)

    version_id
  end

  @spec current_project(atom | %{assigns: atom | %{current_project_id: integer, projects: list}}) :: any
  defp current_project(socket) do
    socket.assigns.projects
    |> filter_by_id(:id, socket.assigns.current_project_id)
    |> Enum.at(0)
  end

  @spec current_team(%{assigns: atom | %{current_team_id: integer, teams: list}}) :: %User{}
  defp current_team(%{ assigns: %{current_team_id: nil}}), do: Logger.warn("Current Team ID is nil")
  defp current_team(%{ assigns: %{current_team_id: current_team_id, teams: teams }}) do
    teams
    |> filter_by_id(:id, current_team_id)
    |> Enum.at(0)
  end

  defp current_version(socket) do
    Enum.filter(socket.assigns.versions, fn(v) -> v.id == socket.assigns.current_version_id end)
    |> Enum.at(0)
  end

  # Used to Generate Select Lists

  defp available_versions(socket = %{assigns: %{current_project: %{ id: current_project_id }}}) do
    socket
    |> get_type(:versions)
    |> filter_by_id(:project_id, current_project_id)
    |> convert_to_select_list
  end
  defp available_versions(_) do
    Logger.warn("Failed to get available versions, returning empty list")
    []
  end

  defp available_projects(socket) do
    socket.assigns.projects
    |> filter_by_id(:team_id, socket.assigns.current_team.id)
    |> convert_to_select_list()
  end

  defp get_type(socket, type) do
    Map.get(socket.assigns, type)
  end

  defp filter_by_id(list, field, id) do
    Enum.filter(list, fn(p) -> Map.get(p, field) == id end)
  end

  defp convert_to_select_list(list, field \\ :name) do
    Enum.map(list, &{Map.get(&1, field), &1.id})
  end

  defp maybe_current_project_default_version({ :ok, value }, _), do: { :ok, value }
  defp maybe_current_project_default_version({ :nok, _ },
    %{ current_project: %{ default_version_id: default_version_id}}) do
    { :ok, default_version_id }
  end
  defp maybe_current_project_default_version({ :nok, value },
    %{ current_project: %{ default_version_id: nil}}) do
      Logger.warn("Can't get default version, Current Projects default version id is nil")
    { :nok, value }
  end
  defp maybe_current_project_default_version({ :nok, value }, %{ current_project: nil}) do
    Logger.warn("Can't get default version, Current Project is nil")
    { :nok, value }
  end

  defp maybe_first_version_in_assigns({ :ok, value }, _), do: { :ok, value }
  defp maybe_first_version_in_assigns({ :nok, _ }, %{ versions: versions }) do
    { :ok, Enum.at(versions, 0) }
  end
  defp maybe_first_version_in_assigns({ :nok, value }, _) do
    Logger.warn("Can't get first version in assigns")
    { :nok, value }
  end

  defp maybe_value_from_socket(state, socket, key) do
    maybe_value_from_assigns(state, socket.assigns, key)
  end

  defp maybe_value_from_assigns({ :ok, value }, _, _), do: { :ok, value }
  defp maybe_value_from_assigns({ :nok, value }, assigns, key) do
    new_value =
      try do
        Map.get(assigns, key)
      rescue
        _ -> value
      end

    case new_value do
      nil -> { :nok, value }
      _ -> { :ok, new_value }
    end
  end

  defp maybe_current_user_default_team({ :ok, value }, _), do: { :ok, value }
  defp maybe_current_user_default_team({ :nok, value }, assigns) do
    try do
      { :ok, assigns.current_user.default_team_id }
    rescue
      _ -> { :nok, value }
    end
  end

  defp maybe_current_team_default_project_id({ :ok, value }, _), do: { :ok, value }
  defp maybe_current_team_default_project_id({ :nok, _ }, assigns) do
    { :ok, assigns.current_team.default_project_id }
  end
end
