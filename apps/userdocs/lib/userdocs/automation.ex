defmodule UserDocs.Automation do
  @moduledoc """
  The Automation context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo
  alias UserDocs.Web.Page
  alias UserDocs.Web.Annotation
  alias UserDocs.Web.Element

  alias UserDocs.Users.User

  alias UserDocs.Projects

  def details(version_id) do
    Repo.one from version in Projects.Version,
      where: version.id == ^version_id,
      left_join: pages in assoc(version, :pages), order_by: pages.order,
      left_join: elements in assoc(pages, :elements), order_by: elements.name,
      left_join: processes in assoc(version, :processes), order_by: processes.order,
      left_join: annotations in assoc(pages, :annotations), order_by: annotations.name,
      left_join: steps in assoc(processes, :steps), order_by: steps.order,
      left_join: screenshot in assoc(steps, :screenshot), order_by: screenshot.name,
      left_join: annotation in assoc(steps, :annotation), order_by: annotation.name,
      left_join: element in assoc(steps, :element), order_by: element.name,
      left_join: content in assoc(annotation, :content), order_by: content.name,
      preload: [
        :pages,
        pages: :elements,
        pages: {pages, elements: {elements, :strategy}},
        pages: :annotations,
        pages: {pages, annotations: {annotations, :annotation_type}},
        processes: {processes, :steps},
        processes: {processes, steps: {steps, :step_type}},
        processes: {processes, steps: {steps, :element}},
        processes: {processes, steps: {steps, :annotation}},
        processes: {processes, steps: {steps, :screenshot}},
        processes: {processes, steps: {steps, :page}},
        processes: {processes, steps: {steps, element: {element, :strategy}}},
        processes: {processes, steps: {steps, annotation: {annotation, :annotation_type}}},
        processes: {processes, steps: {steps, annotation: {annotation, :content}}},
        processes: {processes, steps: {steps, annotation: {annotation, content: {content, :content_versions}}}}
      ]
  end

  def project_details(user_id) do
    Repo.one from user in User,
      where: user.id == ^user_id,
      left_join: teams in assoc(user, :teams),
      left_join: projects in assoc(teams, :projects),
      preload: [
        :teams,
        teams: :projects,
        teams: {teams, projects: {projects, :versions}}
      ]
  end
  def project_details(user, state, opts) do
    preloads = [
      user: :teams,
      user: {:teams, :projects},
      user: {:teams, {:projects, {:projects, :versions}}}
    ]
    state
    |> StateHandlers.preload(user, preloads, opts)
  end

  alias UserDocs.Automation.StepType

  def load_step_types(state, opts) do
    StateHandlers.load(state, list_step_types(), StepType, opts)
  end

  @doc """
  Returns the list of step_types.

  ## Examples

      iex> list_step_types()
      [%StepType{}, ...]

  """
  def list_step_types(state, opts) when is_list(opts) do
    StateHandlers.list(state, StepType, opts)
  end
  def list_step_types(params \\ %{}) do
    filters = Map.get(params, :filters, [])
    base_step_types_query()
    |> maybe_filter_by_name(filters[:name])
    |> Repo.all()
  end

  defp base_step_types_query(), do: from(step_type in StepType)

  defp maybe_filter_by_name(query, nil), do: query
  defp maybe_filter_by_name(query, name) do
    from(step_type in query,
      where: step_type.name == ^name
    )
  end

  @doc """
  Gets a single step_type.

  Raises `Ecto.NoResultsError` if the Step type does not exist.

  ## Examples

      iex> get_step_type!(123)
      %StepType{}

      iex> get_step_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_step_type!(id), do: Repo.get!(StepType, id)
  def get_step_type!(%{ step_types: step_types }, id), do: get_step_type!(step_types, id)
  def get_step_type!(step_types, id) when is_list(step_types) do
    base_step_type_query(id)
    |> Repo.one!()
  end
  def get_step_type!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, StepType, opts)
  end

  def base_step_type_query(id) do
    from(step_type in StepType, where: step_type.id == ^id)
  end

  @doc """
  Creates a step_type.

  ## Examples

      iex> create_step_type(%{field: value})
      {:ok, %StepType{}}

      iex> create_step_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_step_type(attrs \\ %{}) do
    %StepType{}
    |> StepType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a step_type.

  ## Examples

      iex> update_step_type(step_type, %{field: new_value})
      {:ok, %StepType{}}

      iex> update_step_type(step_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_step_type(%StepType{} = step_type, attrs) do
    step_type
    |> StepType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a step_type.

  ## Examples

      iex> delete_step_type(step_type)
      {:ok, %StepType{}}

      iex> delete_step_type(step_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_step_type(%StepType{} = step_type) do
    Repo.delete(step_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking step_type changes.

  ## Examples

      iex> change_step_type(step_type)
      %Ecto.Changeset{data: %StepType{}}

  """
  def change_step_type(%StepType{} = step_type, attrs \\ %{}) do
    StepType.changeset(step_type, attrs)
  end

  alias UserDocs.Automation.Step

  def load_steps(state, opts) do
    StateHandlers.load(state, list_steps(opts[:params], opts[:filters]), Step, opts)
  end

  @doc """
  Returns the list of steps.

  ## Examples

      iex> list_steps()
      [%Step{}, ...]

  """
  def list_steps(params \\ %{}, filters \\ %{})
  def list_steps(params, filters) when is_map(params) and is_map(filters) do
    base_steps_query()
    |> maybe_filter_by_process(filters[:process_id])
    |> maybe_filter_steps_by_version(filters[:version_id])
    |> maybe_filter_by_team(filters[:team_id])
    |> maybe_preload_step_process(params[:processes])
    |> maybe_preload_annotation(params[:annotation])
    |> maybe_preload_annotation_type(params[:annotation_type])
    |> maybe_preload_screenshot(params[:screenshot])
    |> maybe_preload_step_type(params[:step_type])
    |> maybe_preload_element(params[:element])
    |> maybe_preload_content_versions(params[:content_versions])
    |> Repo.all()
  end
  def list_steps(state, opts) when is_list(opts) do
    StateHandlers.list(state, Step, opts)
    |> maybe_preload_step(opts[:preloads], state, opts)
  end

  defp maybe_filter_by_process(query, nil), do: query
  defp maybe_filter_by_process(query, process_id) do
    from(step in query,
      where: step.process_id == ^process_id,
      order_by: step.order
    )
  end

  defp maybe_filter_steps_by_version(query, nil), do: query
  defp maybe_filter_steps_by_version(query, version_id) do
    from(step in query,
      left_join: process in assoc(step, :process),
      where: process.version_id == ^version_id,
      order_by: step.order
    )
  end

  defp maybe_preload_annotation_type(query, nil), do: query
  defp maybe_preload_annotation_type(query, _) do
    from(step in query,
      left_join: annotation in assoc(step, :annotation), order_by: annotation.name,
      left_join: annotation_type in assoc(annotation, :annotation_type),
      preload: [
        :annotation,
        annotation: :annotation_type
      ])
  end

  defp maybe_filter_by_team(query, nil), do: query
  defp maybe_filter_by_team(query, team_id) do
    from(step in query,
      left_join: process in assoc(step, :process),
      left_join: version in assoc(process, :version),
      left_join: project in assoc(version, :project),
      where: project.team_id == ^team_id,
      order_by: step.order
    )
  end

  defp maybe_preload_content_versions(query, nil), do: query
  defp maybe_preload_content_versions(query, _) do
    from(step in query,
      left_join: annotation in assoc(step, :annotation), order_by: annotation.name,
      left_join: content in assoc(annotation, :content), order_by: content.name,
      preload: [
        :annotation,
        annotation: :content,
        annotation: {annotation, content: {content, :content_versions}}
      ])
  end

  defp maybe_preload_step_type(query, nil), do: query
  defp maybe_preload_step_type(query, _), do: from(steps in query, preload: [:step_type])

  defp maybe_preload_annotation(query, nil), do: query
  defp maybe_preload_annotation(query, _), do: from(steps in query, preload: [:annotation])

  defp maybe_preload_screenshot(query, nil), do: query
  defp maybe_preload_screenshot(query, _), do: from(steps in query, preload: [:screenshot])

  defp maybe_preload_step_process(query, nil), do: query
  defp maybe_preload_step_process(query, _), do: from(steps in query, preload: [:process])

  defp maybe_preload_element(query, nil), do: query
  defp maybe_preload_element(query, _), do: from(steps in query, preload: [:element])

  @doc """
  Gets a single step.

  Raises `Ecto.NoResultsError` if the Step does not exist.

  ## Examples

      iex> get_step!(123)
      %Step{}

      iex> get_step!(456)
      ** (Ecto.NoResultsError)

  """
  def get_step!(id) do
    Repo.one! from step in Step,
      where: step.id == ^id,
      left_join: annotation in assoc(step, :annotation),
      left_join: element in assoc(step, :element),
      preload: [
        :page,
        :annotation,
        :element,
        :step_type,
        :process,
        :screenshot,
        annotation: {annotation, :annotation_type},
        element: {element, :strategy},
      ]
  end

  def get_step!(id, params \\ %{}) do
    base_step_query(id)
    |> maybe_preload_element(params[:element])
    |> maybe_preload_annotation(params[:element])
    |> Repo.one!()
  end

  defp base_step_query(id) do
    from(step in Step, where: step.id == ^id)
  end

  def get_step!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Step, opts)
    |> maybe_preload_step(opts[:preloads], state, opts)
  end

  defp maybe_preload_step(step, nil, _, _), do: step
  defp maybe_preload_step(step, _preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, step, opts)
  end

  #def step_status(%Step{ screenshot} = step)

  @doc """
  Creates a step.

  ## Examples

      iex> create_step(%{field: value})
      {:ok, %Step{}}

      iex> create_step(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_step(attrs \\ %{}) do
    %Step{  }
    |> Step.changeset(attrs)
    |> Repo.insert()
  end

  def create_nested_step(attrs) do
    { :ok, step } =
      %Step{}
      |> Step.fields_changeset(attrs)
      |> Repo.insert()

    step
    |> Map.put(:element, nil)
    |> Map.put(:annotation, nil)
    |> Map.put(:page, nil)
    |> Ecto.Changeset.cast(attrs, [])
    |> Step.assoc_changeset()
    |> Repo.update()
  end

  @doc """
  Updates a step.

  ## Examples

      iex> update_step(step, %{field: new_value})
      {:ok, %Step{}}

      iex> update_step(step, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_step(%Step{} = step, attrs) do
    Step.changeset(step, attrs)
    |> Repo.update()
  end

  def runner_update_step(%Step{} = step, attrs) do
    Step.runner_changeset(step, attrs)
    |> Repo.update()
  end

  def update_nested_step(%Step{} = step, last_step, attrs, socket, action) do
    Step.nested_changeset(step, last_step, attrs, socket, action)
    |> Repo.update()
  end

  def put_blank_step_instance(%Step{} = step, process_instance_id \\ nil) do
    attrs = %{ status: "not_started", step_id: step.id, name: step.name, order: step.order, process_instance_id: process_instance_id }
    { :ok, step_instance } = UserDocs.StepInstances.create_step_instance(attrs)
    Map.put(step, :last_step_instance, step_instance)
  end

  def clear_last_step_instance(%Step{} = step) do
    Map.put(step, :last_step_instance, nil)
  end

  def new_step_element(step, changeset) do
    new_step_nested_object(step, changeset, :element_id, :element, %Element{})
  end

  def new_step_page(step, changeset) do
    new_step_nested_object(step, changeset, :page_id, :page, %Page{})
  end

  def new_step_annotation(step, changeset) do
    new_step_nested_object(step, changeset, :annotation_id, :annotation, %Annotation{})
  end

  def new_step_nested_object(step, changeset, foreign_key, object_key, struct) do
    step = clear_association(step, foreign_key, object_key)
    changeset
    |> put_nested_struct_in_changes(step, object_key, struct)
    |> Ecto.Changeset.put_change(foreign_key, nil)
  end

  def clear_association(step, foreign_key, key) do
    { :ok, new_step } =
      step
      |> Step.changeset(%{ foreign_key => nil })
      |> Repo.update()

    Map.put(new_step, key, nil)
  end

  def clear_nested_changes(changeset, keys) do
    Enum.reduce(keys, changeset,
      fn(change_key, changeset) ->
        Ecto.Changeset.delete_change(changeset, change_key)
      end
    )
  end

  def put_nested_struct_in_changes(changeset, step, key, struct) do
    step
    |> Step.changeset(changeset.params)
    |> Ecto.Changeset.put_change(key, struct)
  end

  defp base_steps_query(), do: from(steps in Step)

  def action(:insert), do: "create"
  def action(:update), do: "update"


  @doc """
  Deletes a step.

  ## Examples

      iex> delete_step(step)
      {:ok, %Step{}}

      iex> delete_step(step)
      {:error, %Ecto.Changeset{}}

  """
  def delete_step(%Step{} = step) do
    Repo.delete(step)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking step changes.

  ## Examples

      iex> change_step(step)
      %Ecto.Changeset{data: %Step{}}

  """
  def change_step(%Step{} = step, attrs \\ %{}) do
    Step.changeset(step, attrs)
  end

  def change_nested_step(%Step{} = step, %Step{} = last_step, attrs \\ %{}, state, validate) do
    Step.nested_changeset(step, last_step, attrs, state, validate)
  end

  alias UserDocs.Automation.Process

  def load_processes(state, opts) do
    StateHandlers.load(state, list_processes(%{}, opts[:filters]), Process, opts)
  end

  @doc """
  Returns the list of processes.

  ## Examples

      iex> list_processes()
      [%Process{}, ...]

  """
  def list_processes(params \\ %{}, filters \\ %{})
  def list_processes(state, opts) when is_list(opts) do
    StateHandlers.list(state, Process, opts)
    |> maybe_preload_process(opts[:preloads], state, opts)
  end
  def list_processes(params, filters) when is_map(params) and is_map(filters) do
    base_processes_query()
    |> maybe_filter_by_version(filters[:version_id])
    |> maybe_filter_processes_by_user_id(filters[:user_id])
    |> maybe_filter_processes_by_team_id(filters[:team_id])
    |> Repo.all()
  end


  defp maybe_preload_process(process, nil, _, _), do: process
  defp maybe_preload_process(process, _preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, process, opts)
  end

  defp maybe_filter_by_version(query, nil), do: query
  defp maybe_filter_by_version(query, version_id) do
    from(process in query,
      where: process.version_id == ^version_id
    )
  end

  defp maybe_filter_processes_by_user_id(query, nil), do: query
  defp maybe_filter_processes_by_user_id(query, user_id) do
    from(process in query,
      left_join: version in assoc(process, :version),
      left_join: project in assoc(version, :project),
      left_join: team in assoc(project, :team),
      left_join: user in assoc(team, :users),
      where: user.id == ^user_id
    )
  end

  defp maybe_filter_processes_by_team_id(query, nil), do: query
  defp maybe_filter_processes_by_team_id(query, team_id) do
    from(process in query,
      left_join: version in assoc(process, :version),
      left_join: project in assoc(version, :project),
      left_join: team in assoc(project, :team),
      where: team.id == ^team_id
    )
  end


  defp base_processes_query(), do: from(processes in Process)

  @doc """
  Gets a single process.

  Raises `Ecto.NoResultsError` if the Process does not exist.

  ## Examples

      iex> get_process!(123)
      %Process{}

      iex> get_process!(456)
      ** (Ecto.NoResultsError)

  """
  def get_process!(id, params \\ %{})
  def get_process!(id, %{ preloads: "*"}) do
    Repo.one! from process in Process,
      where: process.id == ^id,
      left_join: step in assoc(process, :steps),
      left_join: page in assoc(step, :page),
      left_join: screenshot in assoc(step, :screenshot),
      left_join: step_type in assoc(step, :step_type),
      left_join: annotation in assoc(step, :annotation),
      left_join: annotation_type in assoc(annotation, :annotation_type),
      left_join: element in assoc(step, :element),
      left_join: strategy in assoc(element, :strategy),
      preload: [
        steps: { step,
          page: page,
          annotation: annotation,
          element: element,
          step_type: step_type,
          process: process,
          screenshot: screenshot,
          annotation: { annotation, annotation_type: annotation_type }
        }
      ]
  end
  def get_process!(id, params) do
    base_process_query(id)
    |> maybe_preload_pages(params[:pages])
    |> maybe_preload_versions(params[:versions])
    |> Repo.one!()
  end
  def get_process!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Process, opts)
    |> maybe_preload_process(opts[:preloads], state, opts)
  end

  defp base_process_query(id) do
    from(process in Process, where: process.id == ^id)
  end

#TODO Remove
  defp maybe_preload_pages(query, nil), do: query
  defp maybe_preload_pages(query, _), do: from(processes in query, preload: [:pages])
#TODO Remove
  defp maybe_preload_versions(query, nil), do: query
  defp maybe_preload_versions(query, _), do: from(processes in query, preload: [:versions])


  @doc """
  Creates a process.

  ## Examples

      iex> create_process(%{field: value})
      {:ok, %Process{}}

      iex> create_process(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_process(attrs \\ %{}) do
    %Process{}
    |> Process.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a process.

  ## Examples

      iex> update_process(process, %{field: new_value})
      {:ok, %Process{}}

      iex> update_process(process, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_process(%Process{} = process, attrs) do
    process
    |> Process.changeset(attrs)
    |> Repo.update()
  end

  def put_blank_process_and_step_instances(%Process{} = process) do
    attrs = %{ status: "not_started", process_id: process.id, name: process.name, order: process.order }
    { :ok, process_instance } = UserDocs.ProcessInstances.create_process_instance(attrs)
    steps = Enum.map(process.steps, fn(step) -> put_blank_step_instance(step, process_instance.id) end)

    process
    |> Map.put(:last_process_instance, process_instance)
    |> Map.put(:steps, steps)
  end

  def clear_last_process_instance(%Process{} = process) do
    Map.put(process, :last_process_instance, nil)
  end

  @doc """
  Deletes a process.

  ## Examples

      iex> delete_process(process)
      {:ok, %Process{}}

      iex> delete_process(process)
      {:error, %Ecto.Changeset{}}

  """
  def delete_process(%Process{} = process) do
    Repo.delete(process)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking process changes.

  ## Examples

      iex> change_process(process)
      %Ecto.Changeset{data: %Process{}}

  """
  def change_process(%Process{} = process, attrs \\ %{}) do
    Process.changeset(process, attrs)
  end
end
