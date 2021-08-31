defmodule UserDocsWeb.State do

  require Logger

  alias UserDocs.Documents
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Web
  alias UserDocs.Users

  def filter_by(list, key, id) do
    list
    |> Enum.filter(fn(o) -> Map.get(o, key) == id end)
  end

  def update_object(state, type, id, object) do
    # Logger.debug("Updating #{type} #{id}. #{field} to #{value}")
    values =
      state
      |> Map.get(type)
      |> Enum.map(fn(o) -> if o.id == id do object else o end end)

    Map.put(%{}, type, values)
  end

  def update_object_field(state, type, id, field, value) do
    # Logger.debug("Updating #{type} #{id}. #{field} to #{value}")
    values =
      state
      |> Map.get(type)
      |> Enum.map(fn(o) -> if o.id == id do Map.put(o, field, value) else o end end)

    Map.put(%{}, type, values)
  end

  def version(state, version_id) do
    state.versions
    |> Enum.filter(fn(v) -> v.id == version_id end)
    |> Enum.at(0)
  end

  def apply_changes(socket, changes) do
    #Enum.reduce(changes, socket, fn({x, y}, acc) -> Phoenix.LiveView.assign(acc, x, y) end)
    Enum.reduce(changes, socket,
      fn({key, value}, current_socket) ->
        # IO.puts("Updating Key #{key}")
        current_socket = Phoenix.LiveView.assign(current_socket, key, value)
        # IO.puts("Updated value to #{Map.get(current_socket, key)}")
        current_socket
      end
    )

  end

  # Used for Automation, don't remove
  def update(state, version_id, team_id) do
    Logger.debug("Updating state")

    state
    |> Map.put(:available_annotation_types, annotation_types())
    |> Map.put(:available_step_types, step_types())
    |> Map.put(:available_processes, processes(version_id))
    |> Map.put(:available_elements, elements(team_id))
    |> Map.put(:strategies, strategies())
  end

  def initialize_user(state, user_id) do
    state
    |> Map.put(:teams, teams(user_id))
    |> Map.put(:team_users, team_users(user_id))
  end

  def initialize_version(state, version_id) do
    state
    |> Map.put(:processes, processes(version_id))
    |> Map.put(:elements, elements(version_id))
  end

  def team_users(user_id) do
    Users.list_team_users(%{}, %{user_id: user_id})
  end

  def teams(user_id) do
    Users.list_teams(%{}, %{user_id: user_id})
  end

  def processes(version_id) do
    Automation.list_processes(%{}, %{version_id: version_id})
  end

  def steps(version_id) do
    Automation.list_steps(%{}, %{version_id: version_id})
  end

  def elements(version_id) do
    Web.list_elements(%{}, %{version_id: version_id})
  end

  def pages(version_id) do
    Web.list_pages(%{}, %{version_id: version_id})
  end

  def annotations(version_id) do
    Web.list_annotations(%{}, %{version_id: version_id})
  end

  def step_types do
    Automation.list_step_types()
  end

  def annotation_types do
    Web.list_annotation_types()
  end

  @spec strategies :: any
  def strategies do
    Web.list_strategies()
  end

  def versions(user_id) do
    Projects.list_versions(%{}, %{user_id: user_id})
  end

  def projects(user_id) do
    Projects.list_projects(%{}, %{user_id: user_id})
  end

  def plural("element"), do: "elements"
  def plural("step"), do: "steps"
  def plural("annotation"), do: "annotations"
  def plural(item) do
    raise(ArgumentError, "Plural not implemented for #{item}")
  end

  def report(socket) do
    teams =
      try do
        Enum.count(socket.assigns.teams)
      rescue
        _ -> raise(RuntimeError, "Failed to query teams for state report")
      end
    team_users =
      try do
        Enum.count(socket.assigns.team_users)
      rescue
        _ -> raise(RuntimeError, "Failed to query team_users for state report")
      end
    projects =
      try do
        Enum.count(socket.assigns.projects)
      rescue
        _ -> raise(RuntimeError, "Failed to query projects for state report")
      end
    versions =
      try do
        Enum.count(socket.assigns.versions)
      rescue
        _ -> raise(RuntimeError, "Failed to query versions for state report")
      end
    strategies =
      try do
        Enum.count(socket.assigns.strategies)
      rescue
        _ -> raise(RuntimeError, "Failed to query strategies for state report")
      end
    log_string =
      """
        Teams: #{teams}
        Team_users: #{team_users}
        Projects: #{projects}
        Versions: #{versions}
        strategies: #{strategies}
      """
    Logger.info(log_string)

    socket
  end
end
