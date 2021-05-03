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

  defp maybe_preload_step_instances(query, nil), do: query
  defp maybe_preload_step_instances(query, _), do: from(users in query, preload: [:step_instances])

  defp maybe_preload_process_instances(query, nil), do: query
  defp maybe_preload_process_instances(query, _), do: from(users in query, preload: [:process_instances])

  defp base_jobs_query(), do: from(jobs in Job)

  def get_job!(id, params \\ %{})
  def get_job!(id, %{ preloads: "*" }) do
    from(j in Job, as: :job)
    |> where([job: j], j.id == ^id)
    |> join(:left, [job: j], process_instances in assoc(j, :process_instances), as: :pi)
    |> join(:left, [job: j], step_instances in assoc(j, :step_instances), as: :si)
    |> join(:left, [si: si], steps in assoc(si, :step), as: :s)
    |> join(:left, [s: s], st in assoc(s, :step_type), as: :st)
    |> join(:left, [s: s], a in assoc(s, :annotation), as: :a)
    |> join(:left, [s: s], p in assoc(s, :page), as: :page)
    |> join(:left, [s: s], e in assoc(s, :element), as: :e)
    |> join(:left, [s: s], s in assoc(s, :screenshot), as: :screenshot)
    |> join(:left, [s: s], pr in assoc(s, :process), as: :process)
    |> join(:left, [e: e], st in assoc(e, :strategy), as: :strategy)
    |> join(:left, [a: a ], at in assoc(a, :annotation_type), as: :at)
    |> join(:left, [pi: pi], process_instance_step_instances in assoc(pi, :step_instances), as: :pi_si)
    |> join(:left, [pi_si: si], steps in assoc(si, :step), as: :pi_si_s)
    |> order_by([pi_si: si], asc: si.order)
    |> join(:left, [pi_si_s: s], st in assoc(s, :step_type), as: :pi_si_st)
    |> join(:left, [pi_si_s: s], a in assoc(s, :annotation), as: :pi_si_a)
    |> join(:left, [pi_si_s: s], p in assoc(s, :page), as: :pi_si_page)
    |> join(:left, [pi_si_s: s], e in assoc(s, :element), as: :pi_si_e)
    |> join(:left, [pi_si_s: s], s in assoc(s, :screenshot), as: :pi_si_screenshot)
    |> join(:left, [pi_si_s: s], pr in assoc(s, :process), as: :pi_si_process)
    |> join(:left, [pi_si_e: e], st in assoc(e, :strategy), as: :pi_si_strategy)
    |> join(:left, [pi_si_a: a ], at in assoc(a, :annotation_type), as: :pi_si_at)
    |> preload([ si: si, s: s, st: st, e: e, strategy: strategy, a: a, at: at, page: page, process: process, screenshot: screenshot ],
      [
        step_instances: { si,
          step: { s, [
            step_type: st,
            element: { e, strategy: strategy },
            annotation: { a, annotation_type: at },
            page: page,
            process: process,
            screenshot: screenshot
          ]}
        }])
    |> preload([ pi: pi, pi_si: pi_si, pi_si_s: s, pi_si_st: st,
      pi_si_e: e, pi_si_strategy: strategy, pi_si_a: a, pi_si_at: at,
      pi_si_screenshot: screenshot, pi_si_page: page, pi_si_process: process ],
      [
        process_instances: { pi,
          step_instances: { pi_si,
            step: { s, [
              step_type: st,
              element: { e, strategy: strategy },
              annotation: { a, annotation_type: at },
              page: page,
              process: process,
              screenshot: screenshot
            ]}
        }}])
    |> Repo.one()
  end
  def get_job!(id, params) do
    preloads = Map.get(params, :preloads, [])
    base_job_query(id)
    |> maybe_preload_step_instances(preloads[:step_instances])
    |> maybe_preload_process_instances(preloads[:process_instances])
    |> Repo.one!()
  end

  defp base_job_query(id) do
    from(job in Job, where: job.id == ^id)
  end

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

  def get_executable_items(nil), do: []
  def get_executable_items(%Job{ } = job) do
    job.step_instances
    ++ job.process_instances
    |> Enum.sort(fn(o1, o2) -> o1.order < o2.order end)
  end
  def get_executable_items(%Ecto.Association.NotLoaded{}), do: [] # TODO: Fix root cause, thiss is bs

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
