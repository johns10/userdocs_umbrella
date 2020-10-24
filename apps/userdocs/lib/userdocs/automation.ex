defmodule UserDocs.Automation do
  @moduledoc """
  The Automation context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo
  alias UserDocsWeb.Endpoint

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
        processes: {processes, steps: {steps, screenshot: {screenshot, :file}}},
        processes: {processes, steps: {steps, annotation: {annotation, :annotation_type}}},
        processes: {processes, steps: {steps, annotation: {annotation, :content}}},
        processes: {processes, steps: {steps, annotation: {annotation, content: {content, :content_versions}}}}
      ]
  end

  alias UserDocs.Automation.StepType

  @doc """
  Returns the list of step_types.

  ## Examples

      iex> list_step_types()
      [%StepType{}, ...]

  """
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

  @doc """
  Returns the list of steps.

  ## Examples

      iex> list_steps()
      [%Step{}, ...]

  """
  def list_steps(params \\ %{}, filters \\ %{}) do
    base_steps_query()
    |> maybe_filter_by_process(filters[:process_id])
    |> maybe_filter_steps_by_version(filters[:version_id])
    |> maybe_filter_by_team(filters[:team_id])
    |> maybe_preload_processes(params[:processes])
    |> maybe_preload_annotation(params[:annotation])
    |> maybe_preload_annotation_type(params[:annotation_type])
    |> maybe_preload_screenshot(params[:screenshot])
    |> maybe_preload_step_type(params[:step_type])
    |> maybe_preload_element(params[:element])
    |> maybe_preload_content_versions(params[:content_versions])
    |> maybe_preload_file(params[:content_versions])
    |> Repo.all()
  end
  def list_steps(_params, filters, state) do
    UserDocs.State.get(state, :steps, AnnotationType)
    |> maybe_filter_by_process(filters[:process_id], state)
  end

  defp maybe_filter_by_process(query, nil), do: query
  defp maybe_filter_by_process(query, process_id) do
    from(step in query,
      where: step.process_id == ^process_id,
      order_by: step.order
    )
  end
  defp maybe_filter_by_process(steps, nil, _), do: steps
  defp maybe_filter_by_process(steps, process_id, state) do
    state.steps
    |> Enum.filter(fn(s) -> s.process_id == process_id end)
  end

  defp maybe_filter_steps_by_version(query, nil), do: query
  defp maybe_filter_steps_by_version(query, version_id) do
    from(step in query,
      left_join: process in assoc(step, :process),
      where: process.version_id == ^version_id,
      order_by: step.order
    )
  end

  defp maybe_preload_file(query, nil), do: query
  defp maybe_preload_file(query, _) do
    from(step in query,
      left_join: screenshot in assoc(step, :screenshot), order_by: screenshot.name,
      preload: [
        :screenshot,
        screenshot: :file
      ])
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

  defp maybe_preload_processes(query, nil), do: query
  defp maybe_preload_processes(query, _), do: from(steps in query, preload: [:processes])

  defp maybe_preload_element(query, nil), do: query
  defp maybe_preload_element(query, _), do: from(steps in query, preload: [:element])


  defp base_steps_query(), do: from(steps in Step)


  @spec get_step!(any, nil | maybe_improper_list | map) :: any
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


  @doc """
  Creates a step.

  ## Examples

      iex> create_step(%{field: value})
      {:ok, %Step{}}

      iex> create_step(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_step(attrs \\ %{}) do
    {status, step} =
      %Step{}
      |> Step.changeset(attrs)
      |> Repo.insert()

    Endpoint.broadcast("step", "create", step)

    {status, step}
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
    IO.puts("Updatiung step")
    {status, step} =
      step
      |> Step.changeset(attrs)
      |> Repo.update()

    update_children(step)
    Endpoint.broadcast("step", "update", step)

    {status, step}
  end
  def update_children(object) do
    Map.get(object, :annotation)
    object
    |> maybe_update_annotation(Map.get(object, :annotation, nil))
    |> maybe_update_element(Map.get(object, :element, nil))
    |> maybe_update_content(Map.get(object, :content, nil))
  end

  def maybe_update_annotation(object, nil), do: object
  def maybe_update_annotation(_, annotation) do
    Endpoint.broadcast("annotation", "update", annotation)
  end

  def maybe_update_element(object, nil), do: object
  def maybe_update_element(_, element) do
    Endpoint.broadcast("element", "update", element)
  end

  def maybe_update_content(object, nil), do: object
  def maybe_update_content(_, content) do
    IO.puts("Updating content")
    Endpoint.broadcast("content", "update", content)

    content
    |> maybe_update_content_versions(Map.get(content, :content_versions, nil))
  end

  def maybe_update_content_versions(object, nil), do: object
  def maybe_update_content_versions(object, content_versions) do
    IO.puts("Updating content versions")
    Enum.each(content_versions, fn(cv) ->
      Endpoint.broadcast("content_version", "update", cv)
    end)
  end


  def update_step_annotation_id(%Step{} = step, %{ name: name, annotation_id: annotation_id }) do
    step
    |> Step.changeset(%{})
    |> Ecto.Changeset.put_change(:annotation_id, annotation_id)
    |> Ecto.Changeset.put_change(:name, name)
    |> Repo.update()
  end

  def update_step_element_id(%Step{} = step, %{ element_id: element_id }) do
    step
    |> Step.changeset(%{})
    |> Ecto.Changeset.put_change(:element_id, element_id)
    |> Repo.update()
  end

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

  alias UserDocs.Automation.Job

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end

  alias UserDocs.Automation.Process

  @spec list_processes(any, nil | maybe_improper_list | map) :: any
  @doc """
  Returns the list of processes.

  ## Examples

      iex> list_processes()
      [%Process{}, ...]

  """
  def list_processes(_params \\ %{}, filters \\ %{}) do
    base_processes_query()
    |> maybe_filter_by_version(filters[:version_id])
    |> Repo.all()
  end

  defp maybe_filter_by_version(query, nil), do: query
  defp maybe_filter_by_version(query, version_id) do
    from(process in query,
      where: process.version_id == ^version_id
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
  def get_process!(id, params \\ %{}) when is_integer(id) do
    base_process_query(id)
    |> maybe_preload_pages(params[:pages])
    |> maybe_preload_versions(params[:versions])
    |> Repo.one!()
  end
  def get_process!(state, id) when is_integer(id) do
    UserDocs.State.get!(state, id, :processes, Process)
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
    {status, process} =
      %Process{}
      |> Process.changeset(attrs)
      |> Repo.insert()

    Endpoint.broadcast("process", "create", process)

    {status, process}
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
    {status, process} =
      process
      |> Process.changeset(attrs)
      |> Repo.update()

    Endpoint.broadcast("process", "update", process)

    {status, process}
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
