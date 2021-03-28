defmodule UserDocs.Automation do
  @moduledoc """
  The Automation context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo
  alias UserDocs.Subscription

  alias UserDocs.Documents
  alias UserDocs.Web
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
  def list_step_types do
    Repo.all(StepType)
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
    step_types
    |> Enum.filter(fn(st) -> st.id == id end)
    |> Enum.at(0)
  end

  @spec create_step_type(
          :invalid
          | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: any
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
    |> maybe_preload_process(params[:processes])
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

  defp maybe_preload_process(query, nil), do: query
  defp maybe_preload_process(query, _), do: from(steps in query, preload: [:process])

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

  def update_step_two(%Step{} = step, last_step, attrs, socket, action) do
    Step.changeset_two(step, last_step, attrs, socket, action)
    |> IO.inspect()
    |> Repo.update()
  end

  def update_step_with_nested_data(%Step{} = step, attrs, state) do
    with changeset <- Step.change_nested_foreign_keys(step, attrs), # get the changeset with updated foreign keys
      { :ok, step } <- update_nested_step(changeset, state), # Apply to database and get new step
      step <- update_step_preloads(step, changeset.changes, state), # Preload data according to changes
      changeset <- Step.change_remaining(step, changeset.params), # Apply the changeset to the remaining fields
      { :ok, step } <- Repo.update(changeset) # Apply the changes to the database
    do
      { :ok, step }
    else
      err -> err
    end
  end

  def validate_step_with_nested_data(%Step{} = original_step, attrs, state) do
    with changeset <- Step.change_nested_foreign_keys(original_step, attrs),
      { :ok, step } <- update_nested_step(changeset, state),
      step <- update_step_preloads(step, changeset.changes, state),
      changeset <- Step.change_remaining(step, changeset.params),
      { :ok, step } <- Ecto.Changeset.apply_action(changeset, :validate)
    do
      { :ok, step, changeset }
    else
      { :error, changeset } -> { :error, original_step, changeset }
    end
  end

  def update_nested_step(changeset, state) do
    #IO.puts("Updating a step")
    changeset
    |> maybe_update_annotation(state)

    Ecto.Changeset.apply_action(changeset, :update)
  end

  def maybe_annotation_id_change(%{ changes: %{ annotation_id: annotation_id }} = changeset, state) do
    { :ok, step } =
      changeset
      |> Ecto.Changeset.delete_change(:annotation)
      |> Ecto.Changeset.apply_action(:update)

    updated_annotation = Web.get_annotation!(annotation_id, state, state.assigns.state_opts)

    step
    |> Map.put(:annotation, updated_annotation)
    |> Web.change_annotation(%{})
  end

  def maybe_update_annotation(
    %{ changes: %{ annotation: %{ changes: %{ content_id: content_id } } = annotation_changeset }}, state
  ) do
    #IO.puts("Updating an annotation in a step when the content id has changed")
    { :ok, annotation } =
      annotation_changeset
      |> Ecto.Changeset.delete_change(:content)
      |> Ecto.Changeset.apply_action(:update)

    updated_content = Documents.get_content!(content_id, state, state.assigns.state_opts)

    annotation
    |> Map.put(:content, updated_content)
    |> Web.change_annotation(%{})
  end
  def maybe_update_annotation(annotation_changeset, _), do: annotation_changeset

  def maybe_update_content(%{ changes: %{ content: content_changeset }}) do
   #IO.inspect("only the content changed")
    case Ecto.Changeset.apply_action(content_changeset, :update) do
      { :ok, content } -> content
    end
  end
  def maybe_update_content(changeset), do: changeset

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


  #TODO: Move this somewhere else.  Otherwise ok.
  def update_step_preloads(step, changes, state) do
    step
    |> maybe_update_annotation(changes, state)
    |> maybe_update_element(changes, state)
    |> maybe_update_page(changes, state)
    |> maybe_update_content(changes, state)
  end

  def maybe_update_annotation(step, %{ annotation_id: nil }, _), do: Map.put(step, :annotation, nil)
  def maybe_update_annotation(step, %{ annotation_id: annotation_id }, state) when is_integer(annotation_id) do
    opts = Keyword.put(state.assigns.state_opts, :preloads, [ :content, :annotation_type ])
    annotation = UserDocs.Web.get_annotation!(annotation_id, state, opts)
   #IO.puts("Annotations content id will be #{annotation.content_id}.  It's content's id is #{annotation.content.id}")
    step
    |> Map.put(:annotation, annotation)
  end
  def maybe_update_annotation(step, _, _), do: step

  def maybe_update_element(step, %{ element_id: nil }, _), do: Map.put(step, :element, nil)
  def maybe_update_element(step, %{ element_id: element_id }, state) when is_integer(element_id) do
    Map.put(step, :element, StateHandlers.get(state, element_id, Element, state.assigns.state_opts))
  end
  def maybe_update_element(step, _, _), do: step

  def maybe_update_page(step, %{ page_id: nil }, _), do: Map.put(step, :page, nil)
  def maybe_update_page(step, %{ page_id: page_id }, state) when is_integer(page_id) do
    Map.put(step, :page, StateHandlers.get(state, page_id, Page, state.assigns.state_opts))
  end
  def maybe_update_page(step, _, _), do: step

  alias UserDocs.Documents.Content

  def maybe_update_content(step, %{ annotation: %{ content_id: nil } }, _) do
   #IO.puts("changed to content id nil")
    Kernel.put_in(step, [ :annotation, :content ], nil)
  end
  def maybe_update_content(step, %{ annotation: %{ changes: %{ content_id: content_id } } }, state) do
   #IO.puts("domain changed to content id #{content_id}")
    content = StateHandlers.get(state, content_id, Content, state.assigns.state_opts)
    annotation =
      Map.get(step, :annotation)
      |> Map.put(:content, content)
      |> Map.put(:content_id, content_id)

    Map.put(step, :annotation, annotation)
  end
  def maybe_update_content(step, _, _), do: step

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

  def change_step_two(%Step{} = step, %Step{} = last_step, attrs \\ %{}, state, validate) do
    Step.changeset_two(step, last_step, attrs, state, validate)
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
  end
  def list_processes(params, filters) when is_map(params) and is_map(filters) do
    base_processes_query()
    |> maybe_filter_by_version(filters[:version_id])
    |> maybe_filter_processes_by_user_id(filters[:user_id])
    |> Repo.all()
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

  defp maybe_preload_process(processes, nil, _, _), do: processes
  defp maybe_preload_process(processes, _preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, processes, opts)
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
