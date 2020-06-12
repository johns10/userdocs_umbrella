defmodule UserDocs.Automation do
  @moduledoc """
  The Automation context.
  """

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Projects

  def details(version_id) do
    version = Repo.one from version in Projects.Version,
      where: version.id == ^version_id,
      left_join: pages in assoc(version, :pages),
      left_join: processes in assoc(pages, :processes),
      left_join: step in assoc(processes, :steps),
      preload: [
        :pages,
        :processes,
        pages: {pages, processes: {processes, :steps}}
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
  def list_steps do
    Repo.all(Step)
  end

  @doc """
  Gets a single step.

  Raises `Ecto.NoResultsError` if the Step does not exist.

  ## Examples

      iex> get_step!(123)
      %Step{}

      iex> get_step!(456)
      ** (Ecto.NoResultsError)

  """
  def get_step!(id), do: Repo.get!(Step, id)

  @doc """
  Creates a step.

  ## Examples

      iex> create_step(%{field: value})
      {:ok, %Step{}}

      iex> create_step(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_step(attrs \\ %{}) do
    %Step{}
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
    step
    |> Step.changeset(attrs)
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

  alias UserDocs.Automation.Arg

  @doc """
  Returns the list of args.

  ## Examples

      iex> list_args()
      [%Arg{}, ...]

  """
  def list_args do
    Repo.all(Arg)
  end

  @doc """
  Gets a single arg.

  Raises `Ecto.NoResultsError` if the Arg does not exist.

  ## Examples

      iex> get_arg!(123)
      %Arg{}

      iex> get_arg!(456)
      ** (Ecto.NoResultsError)

  """
  def get_arg!(id), do: Repo.get!(Arg, id)

  @doc """
  Creates a arg.

  ## Examples

      iex> create_arg(%{field: value})
      {:ok, %Arg{}}

      iex> create_arg(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_arg(attrs \\ %{}) do
    %Arg{}
    |> Arg.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a arg.

  ## Examples

      iex> update_arg(arg, %{field: new_value})
      {:ok, %Arg{}}

      iex> update_arg(arg, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_arg(%Arg{} = arg, attrs) do
    arg
    |> Arg.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a arg.

  ## Examples

      iex> delete_arg(arg)
      {:ok, %Arg{}}

      iex> delete_arg(arg)
      {:error, %Ecto.Changeset{}}

  """
  def delete_arg(%Arg{} = arg) do
    Repo.delete(arg)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking arg changes.

  ## Examples

      iex> change_arg(arg)
      %Ecto.Changeset{data: %Arg{}}

  """
  def change_arg(%Arg{} = arg, attrs \\ %{}) do
    Arg.changeset(arg, attrs)
  end

  alias UserDocs.Automation.Process

  @doc """
  Returns the list of processes.

  ## Examples

      iex> list_processes()
      [%Process{}, ...]

  """
  def list_processes do
    Repo.all from Process,
      preload: [:versions, :pages]
  end

  @doc """
  Gets a single process.

  Raises `Ecto.NoResultsError` if the Process does not exist.

  ## Examples

      iex> get_process!(123)
      %Process{}

      iex> get_process!(456)
      ** (Ecto.NoResultsError)

  """
  def get_process!(id) do
    Repo.one from process in Process,
      where: process.id == ^id,
      preload: [:versions, :pages]
  end

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
    attrs = 
      attrs
      |> fetch_process_versions
      |> fetch_process_pages

    process
    |> Process.changeset(attrs)
    |> Repo.update()
  end
  def fetch_process_versions(attrs = %{"versions" => versions}) do
    versions = 
      UserDocs.Projects.Version
      |> where([version], version.id in ^attrs["versions"])
      |> Repo.all()

    Map.put(attrs, "versions", versions)
  end
  def fetch_process_versions(attrs), do: attrs

  def fetch_process_pages(attrs = %{"pages" => pages}) do
    pages = 
      UserDocs.Web.Page
      |> where([page], page.id in ^attrs["pages"])
      |> Repo.all()

    Map.put(attrs, "pages", pages)
  end
  def fetch_process_pages(attrs), do: attrs

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

  alias UserDocs.Automation.VersionProcess

  @doc """
  Returns the list of version_process.

  ## Examples

      iex> list_version_process()
      [%VersionProcess{}, ...]

  """
end
