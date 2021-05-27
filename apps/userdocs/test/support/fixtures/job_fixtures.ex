defmodule UserDocs.JobsFixtures do

  alias UserDocs.Jobs
  alias UserDocs.StepInstances
  alias UserDocs.ProcessInstances
  alias UserDocs.JobInstances

  def step_instance(step_id \\ nil, job_id \\ nil, process_instance_id \\ nil) do
    {:ok, step_instance } =
      step_instance_attrs(:valid, step_id, job_id, process_instance_id)
      |> StepInstances.create_step_instance()

    step_instance
  end

  def step_instance_attrs(_type, step_id \\ nil, job_id \\ nil, process_instance_id \\ nil)
  def step_instance_attrs(:valid, step_id, job_id, process_instance_id) do
    %{
      uuid: UUID.uuid4(),
      order: 1,
      status: "not_started",
      name: UUID.uuid4(),
      errors: [],
      warnings: [],
      step_id: step_id,
      job_id: job_id,
      process_instance_id: process_instance_id
    }
  end
  def step_instance_attrs(:invalid, step_id, job_id, process_instance_id) do
    %{
      uuid: nil,
      order: nil,
      status: nil,
      name: nil,
      errors: [],
      warnings: [],
      step_id: step_id,
      job_id: job_id,
      process_instance_id: process_instance_id
    }
  end

  def process_instance(process_id \\ nil, job_id \\ nil, _step_instances \\ []) do
    {:ok, process_instance } =
      process_instance_attrs(:valid, process_id, job_id)
      |> ProcessInstances.create_process_instance()

      process_instance
  end

  def process_instance_attrs(status, process_id \\ nil, job_id \\ nil)
  def process_instance_attrs(:valid, process_id, job_instance_id) do
    %{
      uuid: UUID.uuid4(),
      order: 1,
      status: "not_started",
      name: UUID.uuid4(),
      errors: [],
      warnings: [],
      expanded: false,
      process_id: process_id,
      job_instance_id: job_instance_id
    }
  end
  def process_instance_attrs(:invalid, process_id, job_instance_id) do
    %{
      uuid: nil,
      order: nil,
      status: nil,
      name: nil,
      errors: [],
      warnings: [],
      expanded: false,
      process_id: process_id,
      job_instance_id: job_instance_id
    }
  end

  def job(team_id \\ nil) do
    {:ok, job } =
      job_attrs(:valid, team_id)
      |> Jobs.create_job()

      job
  end

  def job_attrs(:valid, team_id) do
    %{
      team_id: team_id,
      order: 1,
      status: "not_started",
      name: UUID.uuid4(),
      errors: [],
      warnings: []
    }
  end
  def job_attrs(:invalid, team_id) do
    %{
      team_id: team_id,
      order: nil,
      status: nil,
      name: nil,
      errors: %{},
      warnings: []
    }
  end

  def job_instance(job_id \\ nil) do
    {:ok, job_instance } =
      job_instance_attrs(:valid, job_id)
      |> JobInstances.create_job_instance()

    job_instance
  end

  def job_instance_attrs(_type, job_id \\ nil)
  def job_instance_attrs(:valid, job_id) do
    %{
      order: 1,
      status: "not_started",
      name: UUID.uuid4(),
      errors: [],
      warnings: [],
      job_id: job_id
    }
  end
  def job_instance_attrs(:invalid, job_id) do
    %{
      order: nil,
      status: nil,
      name: nil,
      errors: [],
      warnings: [],
      job_id: job_id
    }
  end
end
