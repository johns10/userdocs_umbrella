defmodule UserDocs.JobInstances do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Automation.Step
  alias UserDocs.Jobs.JobInstance
  alias UserDocs.Jobs.Job
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.StepInstances.StepInstance

  def list_job_instances(_params \\ %{}) do
    base_job_instances_query()
    |> Repo.all()
  end

  defp base_job_instances_query(), do: from(job_instances in JobInstance)

  def get_job_instance_by_uuid!(uuid) do
    uuid_job_instance_query(uuid)
    |> Repo.one!()
  end

  def get_job_instance!(id, %{preloads: "*"}) do
    base_job_instance_query(id)
    |> preload(:process_instances)
    |> Repo.one!()
  end
  def get_job_instance!(id, params \\ %{}) do
    preloads = Map.get(params, :preloads, [])
    base_job_instance_query(id)
    |> maybe_preload_step_instances(preloads[:step_instances])
    |> maybe_preload_process_instances(preloads[:process_instances])
    |> Repo.one!()
  end

  defp base_job_instance_query(id) do
    from(job_instance in JobInstance, as: :job_instance)
    |> where([job_instance: ji], ji.id == ^id)
  end

  defp uuid_job_instance_query(uuid) do
    from(job_instances in JobInstance, where: job_instances.uuid == ^uuid)
  end

  defp maybe_preload_step_instances(query, nil), do: query
  defp maybe_preload_step_instances(query, _), do: from(job_instances in query, preload: [:step_instances])

  defp maybe_preload_process_instances(query, nil), do: query
  defp maybe_preload_process_instances(query, _) do
    from(job_instances in query, preload: [process_instances: [:step_instances]])
  end

  def update_job_instance_process_instance(%JobInstance{} = job_instance, %ProcessInstance{} = process_instance) do
    process_instances =
      Enum.map(job_instance.process_instances,
        fn(inner_process_instance) ->
          if inner_process_instance.id == process_instance.id do
            Map.put(inner_process_instance, :status, process_instance.status)
          else
            process_instance
          end
        end)

    Map.put(job_instance, :process_instances, process_instances)
  end

  alias UserDocs.Jobs.JobStep
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Automation.Process
  def create_job_instance(attrs \\ %{})
  def create_job_instance(%Job{job_steps: job_steps, job_processes: job_processes} = job) do
    attrs = %{
      order: job.order,
      status: "not_started",
      name: job.name,
      type: "job",
      job_id: job.id,
    }

    {:ok, job_instance} = create_job_instance(attrs)
    step_instances = Enum.map(job_steps, fn(js) -> create_step_instance(js, job_instance.id) end)
    process_instances = Enum.map(job_processes, fn(jp) -> create_process_instance(jp, job_instance.id) end)

    {
      :ok,
      job_instance
      |> Map.put(:process_instances, process_instances)
      |> Map.put(:step_instances, step_instances)
    }
  end
  def create_job_instance(attrs) do
    %JobInstance{}
    |> JobInstance.changeset(attrs)
    |> Repo.insert()
  end

  def create_step_instance(%JobStep{step: step} = job_step, job_instance_id) do
    step_instance_attrs =
      UserDocs.StepInstances.base_step_instance_attrs(step, nil)
      |> Map.put(:job_instance_id, job_instance_id)

    {:ok, step_instance} = UserDocs.StepInstances.create_step_instance(step_instance_attrs)

    job_step_attrs = %{step_instance_id: step_instance.id, order: job_step.order}
    {:ok, _job_step} = UserDocs.Jobs.update_job_step(job_step, job_step_attrs)

    Map.put(step_instance, :step, step)
  end
  def create_step_instance(%Step{} = step, process_instance_id) do
    step_instance_attrs =
      UserDocs.StepInstances.base_step_instance_attrs(step, nil)
      |> Map.put(:process_instance_id, process_instance_id)

    {:ok, step_instance} = UserDocs.StepInstances.create_step_instance(step_instance_attrs)

    Map.put(step_instance, :step, step)
  end

  def create_process_instance(%JobProcess{process: %Process{steps: steps} = process} = job_process, job_instance_id) do
    step_instance_attrs = Enum.map(steps,
      fn(step) ->
        UserDocs.StepInstances.base_step_instance_attrs(step, nil)
      end)

    process_instance_attrs =
      UserDocs.ProcessInstances.base_process_instance_attrs(process, step_instance_attrs, job_process.order)
      |> Map.put(:job_instance_id, job_instance_id)

    {:ok, process_instance} =
      %ProcessInstance{}
      |> ProcessInstance.fields_changeset(process_instance_attrs)
      |> UserDocs.Repo.insert()

    step_instances = Enum.map(process.steps, fn(s) -> create_step_instance(s, process_instance.id) end)

    job_process_attrs = %{process_instance_id: process_instance.id, order: job_process.order}
    {:ok, _job_process} = UserDocs.Jobs.update_job_process(job_process, job_process_attrs)

    process_instance
    |> Map.put(:process, process)
    |> Map.put(:step_instances, step_instances)
  end

  def update_job_instance(%JobInstance{} = job_instance, attrs) do
    job_instance
    |> JobInstance.changeset(attrs)
    |> Repo.update()
  end

  def delete_job_instance(%JobInstance{} = job_instance) do
    Repo.delete(job_instance)
  end
end
