defmodule UserDocs.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%TeamUser{}, ...]

  """
  def load_users(state, opts) do
    StateHandlers.load(state, list_users(), User, opts)
  end

  def list_users(params \\ %{}, filters \\ %{})
  def list_users(state, opts) when is_list(opts) do
    StateHandlers.list(state, User, opts)
  end
  def list_users(params, filters) when is_map(params) and is_map(filters) do
    base_users_query()
    |> maybe_filter_by_team(params[:team_id])
    |> maybe_preload_user_teams(params[:team])
    |> Repo.all()
  end

  defp base_users_query(), do: from(users in User)

  defp maybe_filter_by_team(query, nil), do: query
  defp maybe_filter_by_team(query, team_id) do
    from(user in query,
    left_join: team_user in TeamUser, on: user.id == team_user.user_id,
    left_join: team in Team, on: team.id == team_user.team_id,
    where: team_user.team_id == ^team_id
  )
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the Team user does not exist.

  ## Examples

      iex> get_user!(123)
      %TeamUser{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id, params \\ %{}, _filters \\ %{}) do
    base_user_query(id)
    |> maybe_preload_default_team_project_version(params[:team_project_version])
    |> maybe_preload_user_teams(params[:teams])
    |> maybe_preload_user_team_users(params[:team_users])
    |> maybe_preload_user_selected_team(params[:selected_team])
    |> maybe_preload_user_selected_project(params[:selected_project])
    |> maybe_preload_user_selected_version(params[:selected_version])
    |> Repo.one!()
  end

  def get_user!(id, params, _filters, state, opts) do
    StateHandlers.get(state, id, User, opts)
    |> maybe_preload_user_teams(params[:teams], state, opts)
  end

  defp maybe_preload_default_team_project_version(query, nil), do: query
  defp maybe_preload_default_team_project_version(query, preloads) do
    from(user in query,
      left_join: team in assoc(user, :default_team),
      left_join: project in assoc(team, :default_project),
      left_join: version in assoc(project, :default_version),
      preload: [ default_team: team ],
      preload: [ default_team: { team, default_project: project } ],
      preload: [ default_team: { team, default_project: { project, default_version: version } } ]
    )
  end

  defp maybe_preload_user_teams(query, nil), do: query
  defp maybe_preload_user_teams(query, _) do
    from(users in query, preload: [:teams])
  end

  defp maybe_preload_user_team_users(query, nil), do: query
  defp maybe_preload_user_team_users(query, _) do
    from(users in query, preload: [:team_users])
  end

  defp maybe_preload_user_selected_team(query, nil), do: query
  defp maybe_preload_user_selected_team(query, _) do
    from(users in query, preload: [:selected_team])
  end

  defp maybe_preload_user_selected_project(query, nil), do: query
  defp maybe_preload_user_selected_project(query, _) do
    from(users in query, preload: [:selected_project])
  end

  defp maybe_preload_user_selected_version(query, nil), do: query
  defp maybe_preload_user_selected_version(query, _) do
    from(users in query, preload: [:selected_version])
  end

  defp maybe_preload_user_teams(user, nil, _, _), do: user
  defp maybe_preload_user_teams(user, preloads, state, opts) do
    StateHandlers.preload(state, user, preloads, opts)
  end

  defp base_user_query(id) do
    from(user in User, where: user.id == ^id)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %TeamUser{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %TeamUser{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user_options(%User{} = user, attrs) do
    user
    |> User.change_options(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %TeamUser{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %TeamUser{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def change_user_options(%User{} = user, attrs \\ %{}) do
    User.change_options(user, attrs)
  end

  alias UserDocs.Users.TeamUser

  def load_team_users(state, opts) do
    StateHandlers.load(state, list_team_users(%{}, opts[:filters]), TeamUser, opts)
  end
  @doc """
  Returns the list of team_users.

  ## Examples

      iex> list_team_users()
      [%TeamUser{}, ...]

  """
  def list_team_users(params \\ %{}, filters \\ %{}) do
    base_team_users_query()
    |> maybe_preload_teams(params[:team])
    |> maybe_filter_by_user(filters[:user_id])
    |> Repo.all()
  end

  defp maybe_preload_teams(query, nil), do: query
  defp maybe_preload_teams(query, _) do
    from(team_users in query, preload: [:team])
  end

  defp maybe_filter_by_user(query, nil), do: query
  defp maybe_filter_by_user(query, user_id) do
    from(team_user in query,
      where: team_user.user_id == ^user_id
    )
  end

  defp base_team_users_query(), do: from(team_users in TeamUser)

  @doc """
  Gets a single team_user.

  Raises `Ecto.NoResultsError` if the Team user does not exist.

  ## Examples

      iex> get_team_user!(123)
      %TeamUser{}

      iex> get_team_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_user!(id), do: Repo.get!(TeamUser, id)

  @doc """
  Creates a team_user.

  ## Examples

      iex> create_team_user(%{field: value})
      {:ok, %TeamUser{}}

      iex> create_team_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team_user(attrs \\ %{}) do
    %TeamUser{}
    |> TeamUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team_user.

  ## Examples

      iex> update_team_user(team_user, %{field: new_value})
      {:ok, %TeamUser{}}

      iex> update_team_user(team_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team_user(%TeamUser{} = team_user, attrs) do
    team_user
    |> TeamUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team_user.

  ## Examples

      iex> delete_team_user(team_user)
      {:ok, %TeamUser{}}

      iex> delete_team_user(team_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team_user(%TeamUser{} = team_user) do
    Repo.delete(team_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_user changes.

  ## Examples

      iex> change_team_user(team_user)
      %Ecto.Changeset{data: %TeamUser{}}

  """
  def change_team_user(%TeamUser{} = team_user, attrs \\ %{}) do
    TeamUser.changeset(team_user, attrs)
  end

  alias UserDocs.Users.Team

  def load_teams(state, opts) do
    StateHandlers.load(state, list_teams(%{}, opts[:filters]), Team, opts)
  end

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams(params \\ %{}, filters \\ %{})
  def list_teams(state, opts) when is_list(opts) do
    StateHandlers.list(state, Team, opts)
  end
  def list_teams(params, filters) when is_map(params) and is_map(filters) do
    base_teams_query()
    |> maybe_filter_team_by_user(filters[:user_id])
    |> maybe_filter_by_ids(filters[:ids])
    |> maybe_preload_teams_users(params[:users])
    |> Repo.all()
  end

  defp maybe_preload_teams_users(query, nil), do: query
  defp maybe_preload_teams_users(query, _) do
    from(team in query,
      left_join: users in assoc(team, :users)
    )
  end

  defp maybe_filter_team_by_user(query, nil), do: query
  defp maybe_filter_team_by_user(query, user_id) do
    from(team in query,
    left_join: team_user in TeamUser, on: team.id == team_user.team_id,
    left_join: user in User, on: user.id == team_user.user_id,
    where: team_user.user_id == ^user_id
  )
  end

  defp maybe_filter_by_ids(query, nil), do: query
  defp maybe_filter_by_ids(query, ids) do
    from(item in query,
    where: item.id in ^ids
  )
  end

  defp base_teams_query(), do: from(teams in Team)

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id, params \\ %{}) do
    preloads = Map.get(params, :preloads, [])
    base_team_query(id)
    |> maybe_preload_team_users(preloads[:users])
    |> maybe_preload_users(preloads[:users])
    |> maybe_preload_default_project(preloads[:default_project])
    |> maybe_preload_projects(preloads[:projects])
    |> maybe_preload_content(preloads[:content])
    |> Repo.one!()
  end
  def get_team!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Team, opts)
    |> maybe_preload(opts[:preloads], state, opts)
  end

  defp maybe_preload(object, nil, _, _), do: object
  defp maybe_preload(object, preloads, state, opts) do
    StateHandlers.preload(state, object, preloads, opts)
  end

  defp maybe_preload_content(query, nil), do: query
  defp maybe_preload_content(query, _) do
    from(teams in query, preload: [:content])
  end

  defp maybe_preload_users(query, nil), do: query
  defp maybe_preload_users(query, _), do: from(items in query, preload: [:users])

  defp maybe_preload_team_users(query, nil), do: query
  defp maybe_preload_team_users(query, _), do: from(items in query, preload: [:team_users])

  defp maybe_preload_default_project(query, nil), do: query
  defp maybe_preload_default_project(query, _), do: from(items in query, preload: [:default_project])

  defp maybe_preload_projects(query, nil), do: query
  defp maybe_preload_projects(query, _), do: from(items in query, preload: [:projects])

  defp base_team_query(id) do
    from(team in Team, where: team.id == ^id)
  end

  def get_version_team!(id) do
    Repo.one from team in Team,
      left_join: project in UserDocs.Projects.Project, on: project.team_id == team.id,
      left_join: version in UserDocs.Projects.Version, on: version.project_id == project.id,
      where: version.id == ^id
  end

  # TODO: Move this into base query
  def get_annotation_team!(id) do
    Repo.one from team in Team,
      left_join: project in UserDocs.Projects.Project, on: project.team_id == team.id,
      left_join: version in UserDocs.Projects.Version, on: version.project_id == project.id,
      left_join: page in UserDocs.Web.Page, on: page.version_id == version.id,
      left_join: annotation in UserDocs.Web.Annotation, on: annotation.page_id == page.id,
      where: annotation.id == ^id
  end

  # TODO: Move this into base query
  def get_step_team!(id) do
    Repo.one from team in Team,
      left_join: project in UserDocs.Projects.Project, on: project.team_id == team.id,
      left_join: version in UserDocs.Projects.Version, on: version.project_id == project.id,
      left_join: process in UserDocs.Automation.Process, on: process.version_id == version.id,
      left_join: step in UserDocs.Automation.Step, on: step.process_id == process.id,
      where: step.id == ^id
  end

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  #TODO this could be more elegant, probably
  def update_team(%Team{} = team, attrs = %{"users" => _users}) do
    users =
      User
      |> where([user], user.id in ^attrs["users"])
      |> Repo.all()

      attrs = Map.put(attrs, "users", users)

    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end
end
