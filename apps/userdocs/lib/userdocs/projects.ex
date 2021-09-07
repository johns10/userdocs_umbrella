defmodule UserDocs.Projects do
  @moduledoc """
  The Projects context.
  """

  require Logger
  import Ecto.Query, warn: false
  alias UserDocs.Repo
  alias UserDocs.Subscription

  alias UserDocs.Projects.Project

  def load_projects(state, opts) do
    filters = Keyword.get(opts, :filters, %{})
    preloads = Keyword.get(opts, :preloads, %{})
    StateHandlers.load(state, list_projects(preloads, filters), Project, opts)
  end
  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects(params \\ %{}, filters \\ %{})
  def list_projects(state, opts) when is_list(opts) do
    StateHandlers.list(state, Project, opts)
  end
  def list_projects(params, filters) when is_map(params) and is_map(filters) do
    base_projects_query()
    |> maybe_filter_by_team(filters[:team_id])
    |> maybe_filter_projects_by_user(filters[:user_id])
    |> Repo.all()
  end

  defp maybe_filter_by_team(query, nil), do: query
  defp maybe_filter_by_team(query, team_id) do
    from(item in query,
      where: item.team_id == ^team_id
    )
  end

  defp maybe_filter_projects_by_user(query, nil), do: query
  defp maybe_filter_projects_by_user(query, team_id) do
    from(project in query,
      left_join: team in assoc(project, :team),
      left_join: user in assoc(team, :users),
      where: user.id == ^team_id
    )
  end

  def base_projects_query(), do: from(project in Project)

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  # This function is used because I reverted to integer
  # keys on user selections.  I should go back to FK's
  # and get my on_delete stuff right.
  def try_get_project!(id) do
    try do
      get_project!(id)
    rescue
      e ->
        Logger.error("Failed to retreive selected project, error: ")
        Logger.error(e)
        nil
    end
  end

  def get_project!(id, params \\ %{}) when is_map(params) do
    preloads = Map.get(params, :preloads, [])
    base_project_query(id)
    |> maybe_preload_strategy(preloads[:strategy])
    |> Repo.one!()
  end
  def get_project!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Project, opts)
  end
  defp base_project_query(id) do
    from(project in Project, where: project.id == ^id)
  end

  defp maybe_preload_strategy(query, nil), do: query
  defp maybe_preload_strategy(query, _), do: from(processes in query, preload: [:strategy])

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.create_changeset(attrs)
    |> Repo.insert()
    #|> Subscription.broadcast("project", "create")
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
    #|> Subscription.broadcast("project", "update")
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

end
