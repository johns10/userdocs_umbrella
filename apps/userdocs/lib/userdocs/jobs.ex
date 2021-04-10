defmodule UserDocs.Jobs do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.ProcessInstances
  alias UserDocs.ProcessInstances.ProcessInstance

  alias UserDocs.StepInstances
  alias UserDocs.StepInstances.StepInstance

  alias UserDocs.Jobs.Job

  def format_instance(%StepInstance{} = step_instance), do: StepInstances.format_step_instance_for_export(step_instance)
  def format_instance(%ProcessInstance{} = process_instance), do: ProcessInstances.format_process_instance_for_export(process_instance)

  def list_jobs(params \\ %{}) do
    preloads = Map.get(params, :preloads, [])
    base_jobs_query()
    |> maybe_preload_step_instances(preloads[:step_instances])
    |> maybe_preload_process_instances(preloads[:process_instances])
    |> Repo.all()
  end

  def get_job!(id) do
    base_job_query(id)
    |> Repo.one!()
  end

  defp base_job_query(id) do
    from(job in Job, where: job.id == ^id)
  end

  defp maybe_preload_step_instances(query, nil), do: query
  defp maybe_preload_step_instances(query, _), do: from(users in query, preload: [:step_instances])

  defp maybe_preload_process_instances(query, nil), do: query
  defp maybe_preload_process_instances(query, _), do: from(users in query, preload: [:process_instances])

  defp base_jobs_query(), do: from(jobs in Job)

  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end

  def remove_job_step_instance(%Job{} = job, step_id) do
    IO.puts("remove_job_step_instance")
    { step_instance, step_instances } =
      job.step_instances
      |> Enum.reduce({ nil, [] },
        fn(step_instance, { found, remaining }) ->
          if step_instance.id == step_id do
            { step_instance, remaining }
          else
            { found, [ step_instance | remaining ] }
          end
        end)

    case StepInstances.delete_step_instance(step_instance) do
      { :ok, step_instance } ->
        update_job_step_instances(job, step_instances)
      { :error, _changeset } -> { :error, job }
    end
  end

  def update_job_step_instances(%Job{} = job, step_instances) do
    IO.puts("update_job_step_instances")
    IO.inspect(step_instances)
    job
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:step_instances, step_instances)
    |> Repo.update()
  end

  def update_job_step_instance(
    %Job{ step_instances: step_instances } = job,
    %{ "id" => id } = step_instance_attrs
  ) do
    IO.inspect(step_instance_attrs)
    updated_step_instances =
      Enum.map(step_instances,
        fn(step_instance) ->
          case step_instance.id == id do
            true ->
              { :ok, updated_step_instance } = StepInstances.update_step_instance(step_instance, step_instance_attrs)
              updated_step_instance
              |> Map.put(:step, step_instance.step) # TODO: Go get the step?
            false -> step_instance
          end
        end
      )
    { :ok, job } = update_job(job, %{ step_instances: updated_step_instances })
    { :ok, Map.put(job, :step_instances, updated_step_instances)}
  end

  def expand_process_instance(%Job{} = job, id) do
    Ecto.Changeset.change(job, %{})
    process_instances =
      Enum.map(job.process_instances,
        fn(process_instance) ->
          if (process_instance.id == id) do
            { :ok, updated_process_instance } =
              ProcessInstances.toggle_process_instance_expanded(process_instance)

            updated_process_instance
          else
            process_instance
          end
        end
      )

    { :ok, Map.put(job, :process_instances, process_instances)} #TODO
  end

  def add_item_to_job_queue(%Job{} = job, %StepInstance{} = step_instance) do
    attrs = %{
      step_instances: job.step_instances ++ [ step_instance ]
    }
    update_job(job, attrs)
  end

  def add_item_to_job_queue(%Job{} = job, %ProcessInstance{} = process_instance) do
    attrs = %{
      process_instances: job.process_instances ++ [ process_instance ]
    }
    update_job(job, attrs)
  end

  def export_job(%Job{} = job) do
    IO.inspect("Exporting job")
    Enum.reduce(get_executable_items(job), [],
      fn(instance, acc) ->
        case format_instance(instance) do
          %{} = instance -> [ instance | acc ]
          [ _ | _ ] = instances -> instances ++ acc
        end
      end
    )
  end

  def get_executable_items(%Job{ } = job) do
    job.step_instances
    ++ job.process_instances
    |> Enum.sort(fn(o1, o2) -> o1.order < o2.order end)
  end

  def max_order(%Job{ } = job) do
    job.step_instances
    ++ job.process_instances
    |> max_order()
  end
  def max_order([]), do: 0
  def max_order([ _ | _ ] = items) do
    items
    |> Enum.sort(fn(o1, o2) -> o1.order < o2.order end)
    |> Enum.max_by(fn(o) -> o.order end)
    |> Map.get(:order)
  end
end
