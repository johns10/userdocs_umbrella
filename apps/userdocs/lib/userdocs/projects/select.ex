defmodule UserDocs.Projects.Select do
  require Logger

  def initialize(state) do
    %{}
    |> current_team_id(state)
    |> current_team(state)
    |> current_project_id(state)
    |> current_project(state)
    |> current_version_id(state)
    |> current_version(state)
  end

  def initialize_select_options(state) do
    %{}
    |> teams_select_options(state)
    |> projects_select_options(state)
    |> versions_select_options(state)
  end

  def handle_team_selection(state, team_id) do
    %{ current_team_id: team_id }
    |> current_team(state)
    |> projects_select_options(state)
    |> current_project_id(state)
    |> current_project(state)
    |> versions_select_options(state)
    |> current_version_id(state)
    |> current_version(state)
  end

  def handle_project_selection(state, project_id) do
    %{ current_project_id: project_id }
    |> current_project(state)
    |> versions_select_options(state)
    |> current_version_id(state)
    |> current_version(state)
  end

  def handle_version_selection(state, version_id) do
    %{ current_version_id: version_id }
    |> current_version(state)
  end

  defp teams_select_options(changes, %{ teams: teams }) do
    Map.put(changes, :teams_select_options, teams_select_options(teams))
  end
  defp teams_select_options(changes, %{ data: %{ teams: teams }}) do
    Map.put(changes, :teams_select_options, teams_select_options(teams))
  end
  defp teams_select_options(teams) do
    teams
    |> convert_to_select_list()
  end

  def assign_default_team_id(%{ assigns: %{ current_user: %{ default_team_id: team_id}}} = state, loader) do
    loader.(state, :current_team_id, team_id)
  end

  defp current_team_id(changes = %{}, %{ current_user: %{ default_team_id: team_id} }), do: Map.put(changes, :current_team_id, team_id )
  defp current_team_id(_, _), do: raise(ArgumentError, "Select.current_team_id failed to find a team id")

  defp current_team(%{current_team_id: nil}, _), do: raise(ArgumentError, "Select.current_team failed because current team id is nil")
  defp current_team(changes = %{current_team_id: team_id}, %{ teams: teams }) do
    Map.put(changes, :current_team, current_team(teams, team_id))
  end
  defp current_team(changes = %{current_team_id: team_id}, %{ data: %{ teams: teams }}) do
    Map.put(changes, :current_team, current_team(teams, team_id))
  end
  defp current_team(teams, team_id) do
    teams
    |> Enum.filter(fn(t) -> t.id == team_id end)
    |> Enum.at(0)
  end


  defp projects_select_options(changes = %{ current_team_id: team_id }, %{ projects: projects }) do
    Map.put(changes, :projects_select_options, projects_select_options(projects, team_id))
  end
  defp projects_select_options(changes = %{ current_team_id: team_id }, %{ data: %{ projects: projects }}) do
    Map.put(changes, :projects_select_options, projects_select_options(projects, team_id))
  end
  defp projects_select_options(changes, %{ current_team_id: team_id, data: %{ projects: projects }}) do
    Map.put(changes, :projects_select_options, projects_select_options(projects, team_id))
  end
  defp projects_select_options(projects, team_id) do
    projects
    |> Enum.filter(fn(p) -> p.team_id == team_id end)
    |> convert_to_select_list()
  end

  defp current_project_id(changes = %{ current_team: %{ default_project_id: nil } }, _) do
    Logger.warn("Select.current_project_id got a current_team with a nil default_project_id")
    Map.put(changes, :current_project_id, nil)
  end
  defp current_project_id(changes = %{ current_team: current_team }, _) do
    Map.put(changes, :current_project_id, current_team.default_project_id)
  end

  defp current_project(changes = %{ current_project_id: nil }, _) do
    Map.put(changes, :current_project, nil)
  end
  defp current_project(changes = %{ current_project_id: project_id }, %{ projects: projects }) do
    Map.put(changes, :current_project, current_project(projects, project_id))
  end
  defp current_project(changes = %{ current_project_id: project_id }, %{ data: %{ projects: projects }}) do
    Map.put(changes, :current_project, current_project(projects, project_id))
  end
  defp current_project(projects, project_id) do
      projects
    |> Enum.filter(fn(p) -> p.id == project_id end)
    |> Enum.at(0)
  end

  defp versions_select_options(changes = %{ current_project_id: project_id }, %{ versions: versions }) do
    Map.put(changes, :versions_select_options, versions_select_options(versions, project_id))
  end
  defp versions_select_options(changes = %{ current_project_id: project_id }, %{ data: %{ versions: versions }}) do
    Map.put(changes, :versions_select_options, versions_select_options(versions, project_id))
  end
  defp versions_select_options(changes, %{ current_project_id: project_id, data: %{ versions: versions }}) do
    Map.put(changes, :versions_select_options, versions_select_options(versions, project_id))
  end
  defp versions_select_options(versions, project_id) do
    versions
    |> Enum.filter(fn(v) -> v.project_id == project_id end)
    |> convert_to_select_list()
  end

  defp current_version_id(changes = %{ current_project: nil}, _) do
    Logger.warn("Select.current_version_id got a current_team with a nil default_version_id")
    Map.put(changes, :current_version_id, nil)
  end
  defp current_version_id(changes = %{ current_project: %{ default_version_id: version_id }}, _) do
    Map.put(changes, :current_version_id, version_id)
  end

  defp current_version(changes = %{ current_version_id: version_id }, %{ versions: versions }) do
    Map.put(changes, :current_version, current_version(versions, version_id))
  end
  defp current_version(changes = %{ current_version_id: version_id }, %{ data: %{ versions: versions }}) do
    Map.put(changes, :current_version, current_version(versions, version_id))
  end
  defp current_version(versions, version_id) do
    versions
    |> Enum.filter(fn(v) -> v.id == version_id end)
    |> Enum.at(0)
  end

  defp convert_to_select_list(list, field \\ :name) do
    Enum.map(list, &{Map.get(&1, field), &1.id})
  end
end
