defmodule UserDocs.Jobs do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.ProcessInstances
  alias UserDocs.ProcessInstances.ProcessInstance

  alias UserDocs.StepInstances
  alias UserDocs.StepInstances.StepInstance

  alias UserDocs.Jobs.Job

  def list_jobs(params \\ %{}) do
    preloads = Map.get(params, :preloads, [])
    base_jobs_query()
    |> maybe_preload_step_instances(preloads[:step_instances])
    |> maybe_preload_process_instances(preloads[:process_instances])
    |> Repo.all()
  end

  def get_job!(id, params \\ %{}) do
    preloads = Map.get(params, :preloads, [])
    base_job_query(id)
    |> maybe_preload_step_instances(preloads[:step_instances])
    |> maybe_preload_process_instances(preloads[:process_instances])
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

  def add_step_instance_to_job(%Job{} = job, step_id) when is_integer(step_id) do
    { :ok, step_instance } =
      UserDocs.Automation.get_step!(step_id)
      |> StepInstances.create_step_instance_from_job_and_step(job, max_order(job) + 1)

    add_step_instance_to_job(job, step_instance)
  end
  def add_step_instance_to_job(%Job{} = job, %StepInstance{} = step_instance) do
    step_instances = job.step_instances ++ [ step_instance ]
    { :ok, Map.put(job, :step_instances, step_instances) }
  end

  def remove_step_instance_from_job(%Job{} = job, step_instance_id) when is_integer(step_instance_id) do
    step_instance = UserDocs.StepInstances.get_step_instance!(step_instance_id)
    remove_step_instance_from_job(job, step_instance)
  end
  def remove_step_instance_from_job(%Job{} = job, %StepInstance{} = step_instance) do
    case StepInstances.delete_step_instance(step_instance) do
      { :ok, step_instance } ->
        { step_instance, step_instances } =
          pop_item_from_list(job.step_instances, step_instance.id)

        { :ok, Map.put(job, :step_instances, step_instances) }
      { :error, _changeset } -> { :error, job }
    end
  end

  def add_process_instance_to_job(%Job{} = job, process_id) when is_integer(process_id) do
    { :ok, process_instance } =
      UserDocs.AutomationManager.get_process!(process_id)
      |> ProcessInstances.create_process_instance_from_job_and_process(job, max_order(job) + 1)

    add_process_instance_to_job(job, process_instance)
  end
  def add_process_instance_to_job(%Job{} = job, %ProcessInstance{} = process_instance) do
    process_instances = job.process_instances ++ [ process_instance ]
    { :ok, Map.put(job, :process_instances, process_instances) }
  end

  def remove_process_instance_from_job(%Job{} = job, process_instance_id) when is_integer(process_instance_id) do
    process_instance = UserDocs.ProcessInstances.get_process_instance!(process_instance_id)
    remove_process_instance_from_job(job, process_instance)
  end
  def remove_process_instance_from_job(%Job{} = job, %ProcessInstance{} = process_instance) do
    case ProcessInstances.delete_process_instance(process_instance) do
      { :ok, process_instance } ->
        { process_instance, process_instances } =
          pop_item_from_list(job.process_instances, process_instance.id)

        { :ok, Map.put(job, :process_instances, process_instances) }
      { :error, _changeset } -> { :error, job }
    end
  end

  def pop_item_from_list(items, id) do
    Enum.reduce(items, { nil, [] },
      fn(item, { found_item, remaining_items }) ->
        if item.id == id do
          { item, remaining_items }
        else
          { found_item, [ item | remaining_items ] }
        end
      end
    )
  end

  def update_job_step_instance(
    %Job{ process_instances: process_instances } = job,
    %{ "process_instance_id" => process_instance_id, "id" => step_instance_id } = step_instance_attrs
  ) do
    updated_process_instances =
      Enum.map(process_instances, fn(process_instance) ->
        case process_instance.id == process_instance_id do
          true ->
            updated_step_instances = update_this_step_instance(process_instance.step_instances, step_instance_id, step_instance_attrs)
            Map.put(process_instance, :step_instances, updated_step_instances)
          false -> process_instance
        end
      end)

    { :ok, Map.put(job, :process_instances, updated_process_instances)}
  end

  def update_job_step_instance(
    %Job{ step_instances: step_instances } = job,
    %{ "id" => id } = step_instance_attrs
  ) do
    updated_step_instances = update_this_step_instance(step_instances, id, step_instance_attrs)
    { :ok, Map.put(job, :step_instances, updated_step_instances)}
  end

  def update_this_step_instance(step_instances, id, attrs) do
    Enum.map(step_instances, fn(step_instance) ->
      case step_instance.id == id do
        true ->
          { :ok, updated_step_instance } =
            StepInstances.update_step_instance(step_instance, attrs)

          Map.put(updated_step_instance, :step, step_instance.step) # TODO: Go get the step?
        false -> step_instance
      end
    end)
  end

  def reset_job_status(%Job{ process_instances: process_instances, step_instances: step_instances } = job) do
    process_instance_attrs = Enum.map(process_instances,
      fn(%{ step_instances: process_step_instances } = process_instance) ->
        %{ id: process_instance.id, status: "not_started", step_instances: reset_step_instances_status_attrs(process_step_instances) }
      end
    )
    step_instance_attrs = reset_step_instances_status_attrs(step_instances)
    update_job(job, %{ process_instances: process_instance_attrs, step_instances: step_instance_attrs })
  end

  def reset_step_instances_status_attrs(step_instances) do
    Enum.map(step_instances, fn(process_instance) ->
      %{ id: process_instance.id, status: "not_started" }
    end)
  end

  def expand_process_instance(%Job{} = job, id) when is_integer(id) do
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

  def export_job(%Job{} = job) do
    Enum.reduce(get_executable_items(job), [],
      fn(instance, acc) ->
        case format_instance(instance) do
          %{} = instance -> [ instance | acc ]
          [ _ | _ ] = instances -> acc ++ instances
        end
      end
    )
  end

  def format_instance(%StepInstance{} = step_instance), do: StepInstances.format_step_instance_for_export(step_instance)
  def format_instance(%ProcessInstance{} = process_instance), do: ProcessInstances.format_process_instance_for_export(process_instance)

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
