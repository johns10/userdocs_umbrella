defmodule UserDocs.Projects do
  @moduledoc """
  The Projects context.
  """

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
  def get_project!(id, params \\ %{}) when is_map(params) do
    base_project_query(id)
    |> maybe_preload_versions(params[:versions])
    |> maybe_preload_default_version(params[:default_version])
    |> Repo.one!()
  end
  def get_project!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Project, opts)
  end

  defp base_project_query(id) do
    from(project in Project, where: project.id == ^id)
  end

  defp maybe_preload_versions(query, nil), do: query
  defp maybe_preload_versions(query, _), do: from(item in query, preload: [:versions])

  defp maybe_preload_default_version(query, nil), do: query
  defp maybe_preload_default_version(query, _), do: from(item in query, preload: [:default_version])

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
    |> Project.changeset(attrs)
    |> Repo.insert()
    |> Subscription.broadcast("project", "create")
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
    |> Subscription.broadcast("project", "update")
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

  alias UserDocs.Projects.Version

  def load_versions(state, opts) do
    StateHandlers.load(state, list_versions(%{}, opts[:filters]), Version, opts)
  end

  @doc """
  Returns the list of versions.

  ## Examples

      iex> list_versions()
      [%Version{}, ...]

  """
  def list_versions(params \\ %{}, filters \\ %{})
  def list_versions(params, filters) when is_map(params) and is_map(filters) do
    base_versions_query()
    |> maybe_filter_by_project(filters[:project_id])
    |> maybe_filter_version_by_team(filters[:team_id])
    |> maybe_filter_versions_by_user(params[:user_id])
    |> maybe_filter_by_version_ids(filters[:version_ids])
    |> maybe_preload_strategy(params[:strategy])
    |> Repo.all()
  end
  def list_versions(state, opts) when is_list(opts) do
    StateHandlers.list(state, Version, opts)
  end

  defp maybe_preload_strategy(query, nil), do: query
  defp maybe_preload_strategy(query, _), do: from(version in query, preload: [:strategy])

  defp maybe_filter_by_project(query, nil), do: query
  defp maybe_filter_by_project(query, project_id) do
    from(version in query,
      where: version.project_id == ^project_id
    )
  end

  defp maybe_filter_version_by_team(query, nil), do: query
  defp maybe_filter_version_by_team(query, team_id) do
    from(version in query,
      left_join: project in Project,
      on: project.id == version.project_id,
      where: project.team_id == ^team_id
    )
  end

  defp maybe_filter_by_version_ids(query, nil), do: query
  defp maybe_filter_by_version_ids(query, version_ids) do
    from(version in query,
      where: version.id in ^version_ids
    )
  end

  defp maybe_filter_versions_by_user(query, nil), do: query
  defp maybe_filter_versions_by_user(query, user_id) do
    from(version in query,
      left_join: project in assoc(version, :project),
      left_join: team in assoc(project, :team),
      left_join: user in assoc(team, :users),
      where: user.id == ^user_id
    )
  end

  def base_versions_query(), do: from(version in Version)

  @doc """
  Gets a single version.

  Raises `Ecto.NoResultsError` if the Version does not exist.

  ## Examples

      iex> get_version!(123)
      %Version{}

      iex> get_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_version!(id, params \\ %{}, filters \\ %{})
  def get_version!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Version, opts)
    |> maybe_preload_version(opts[:preloads], state, opts)
  end
  def get_version!(id, params, filters) when is_map(filters) and is_map(params) do
    base_version_query(id)
    |> maybe_preload_pages(params[:pages])
    |> Repo.one!()
  end

  defp maybe_preload_version(versions, nil, _, _), do: versions
  defp maybe_preload_version(versions, preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, versions, preloads, opts)
  end

  def get_version!(%{ versions: versions }, id, _params, _filters) do
    versions
    |> Enum.filter(fn(v) -> v.id == id end)
    |> Enum.at(0)
  end

  defp base_version_query(id) do
    from(version in Version, where: version.id == ^id)
  end

  defp maybe_preload_pages(query, nil), do: query
  defp maybe_preload_pages(query, _), do: from(version in query, preload: [:pages])

  # TODO: Move these into the base query
  def get_annotation_version!(id) do
    Repo.one from version in Version,
      left_join: page in UserDocs.Web.Page, on: page.version_id == version.id,
      left_join: annotation in UserDocs.Web.Annotation, on: annotation.page_id == page.id,
      where: annotation.id == ^id
  end
  def get_step_version!(id) do
    Repo.one from version in Version,
      left_join: process in UserDocs.Automation.Process, on: process.version_id == version.id,
      left_join: step in UserDocs.Automation.Step, on: step.process_id == process.id,
      where: step.id == ^id
  end

  @doc """
  Creates a version.

  ## Examples

      iex> create_version(%{field: value})
      {:ok, %Version{}}

      iex> create_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_version(attrs \\ %{}) do
    %Version{}
    |> Version.changeset(attrs)
    |> Repo.insert()
    |> Subscription.broadcast("version", "create")
  end

  @doc """
  Updates a version.

  ## Examples

      iex> update_version(version, %{field: new_value})
      {:ok, %Version{}}

      iex> update_version(version, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_version(%Version{} = version, attrs) do
    version
    |> Version.changeset(attrs)
    |> Repo.update()
    |> Subscription.broadcast("version", "update")
  end

  @doc """
  Deletes a version.

  ## Examples

      iex> delete_version(version)
      {:ok, %Version{}}

      iex> delete_version(version)
      {:error, %Ecto.Changeset{}}

  """
  def delete_version(%Version{} = version) do
    Repo.delete(version)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking version changes.

  ## Examples

      iex> change_version(version)
      %Ecto.Changeset{data: %Version{}}

  """
  def change_version(%Version{} = version, attrs \\ %{}) do
    Version.changeset(version, attrs)
  end
end
