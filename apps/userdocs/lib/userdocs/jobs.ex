defmodule UserDocs.Jobs do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.ProcessInstances
  alias UserDocs.ProcessInstances.ProcessInstance

  alias UserDocs.StepInstances
  alias UserDocs.StepInstances.StepInstance

  alias UserDocs.Automation.Step

  alias UserDocs.Jobs.Job
  alias UserDocs.Jobs.JobStep

  def list_jobs(params \\ %{}) do
    preloads = Map.get(params, :preloads, [])
    base_jobs_query()
    #|> maybe_preload_step_instances(preloads[:step_instances])
    #|> maybe_preload_process_instances(preloads[:process_instances])
    |> Repo.all()
  end
  """
  defp maybe_preload_step_instances(query, nil), do: query
  defp maybe_preload_step_instances(query, _), do: from(users in query, preload: [:step_instances])

  defp maybe_preload_process_instances(query, nil), do: query
  defp maybe_preload_process_instances(query, _), do: from(users in query, preload: [:process_instances])
  """
  defp maybe_preload_steps(query, nil), do: query
  defp maybe_preload_steps(query, _) do
    from(jobs in query)
    |> join(:left, [job: j], js in assoc(j, :job_steps), as: :job_steps)
    |> join(:left, [job_steps: js], step in assoc(js, :step), as: :js_steps)
    |> join(:left, [job_steps: js], si in assoc(js, :step_instance), as: :js_step_instances)
    |> order_by([js_steps: s], asc: s.order)
    |> join(:left, [js_steps: s], st in assoc(s, :step_type), as: :js_step_type)
    |> join(:left, [js_steps: s], a in assoc(s, :annotation), as: :js_annotation)
    |> join(:left, [js_steps: s], p in assoc(s, :page), as: :js_page)
    |> join(:left, [js_steps: s], e in assoc(s, :element), as: :js_element)
    |> join(:left, [js_steps: s], pr in assoc(s, :screenshot), as: :js_screenshot)
    |> join(:left, [js_steps: s], pr in assoc(s, :process), as: :js_process)
    |> join(:left, [js_element: e], st in assoc(e, :strategy), as: :js_strategy)
    |> join(:left, [js_annotation: a ], at in assoc(a, :annotation_type), as: :js_annotation_type)
    |> preload([ job_steps: js, js_steps: s, js_step_type: st, js_element: e, js_strategy: strategy, js_annotation: a,
        js_annotation_type: at, js_page: page, js_process: process, js_screenshot: screenshot, js_step_instances: si ],
      [ job_steps: { js,
          step: { s, [
            last_step_instance: si,
            step_type: st,
            element: { e, strategy: strategy },
            annotation: { a, annotation_type: at },
            page: page,
            process: process,
            screenshot: screenshot ]} } ])
  end

  defp maybe_preload_processes(query, nil), do: query
  defp maybe_preload_processes(query, _) do
    from(jobs in query)
    |> join(:left, [job: j], jp in assoc(j, :job_processes), as: :job_processes)
    |> join(:left, [job_processes: jp], jp in assoc(jp, :process), as: :processes)
    |> order_by([job_processes: jp], asc: jp.order)
    |> preload([ job_processes: jp, processes: p ],
      [ job_processes: { jp,
        process_instance: ^preload_process_instance(),
          process: { p, [
          steps: ^preload_steps_query()
      ]} } ])
  end

  defp maybe_preload_last_job_instance(query, nil), do: query
  defp maybe_preload_last_job_instance(query, _) do
    from(job in query, preload: [ last_job_instance: ^preload_last_job_instance_query() ])
  end

  defp preload_process_instance() do
    from(process_instance in UserDocs.ProcessInstances.ProcessInstance)
    |> order_by(asc: :order)
    |> preload([ step_instances: ^preload_step_instances_query() ])
  end

  defp preload_last_job_instance_query() do
    from(job_instance in UserDocs.Jobs.JobInstance)
    |> order_by(desc: :id)
    |> limit(1)
    |> preload([
      step_instances: ^preload_step_instances_query(),
      process_instances: ^preload_process_instances_query
    ])
  end

  defp preload_process_instances_query() do
    from(process_instances in UserDocs.ProcessInstances.ProcessInstance)
    |> order_by(asc: :order)
    |> preload([ step_instances: ^preload_step_instances_query() ])
  end

  defp preload_step_instances_query() do
    from(step_instances in UserDocs.StepInstances.StepInstance)
    |> order_by(asc: :order)
  end

  defp preload_steps_query() do
    from(step in UserDocs.Automation.Step, as: :steps)
    |> order_by([steps: s], asc: s.order)
    |> join(:left, [steps: s], st in assoc(s, :step_type), as: :step_type)
    |> join(:left, [steps: s], a in assoc(s, :annotation), as: :annotation)
    |> join(:left, [steps: s], p in assoc(s, :page), as: :page)
    |> join(:left, [steps: s], e in assoc(s, :element), as: :element)
    |> join(:left, [steps: s], sc in assoc(s, :screenshot), as: :screenshot)
    |> join(:left, [steps: s], pr in assoc(s, :process), as: :process)
    |> join(:left, [element: e], st in assoc(e, :strategy), as: :strategy)
    |> join(:left, [annotation: a ], at in assoc(a, :annotation_type), as: :annotation_type)
    |> preload([ step_type: step_type ], [ step_type: step_type ])
    |> preload([ annotation: annotation ], [ annotation: annotation ])
    |> preload([ page: page ], [ page: page ])
    |> preload([ element: element ], [ element: element ])
    |> preload([ screenshot: screenshot ], [ screenshot: screenshot ])
    |> preload([ process: process ], [ process: process ])
    |> preload([ annotation: a, annotation_type: at ], [ annotation: { a, annotation_type: at } ])
    |> preload([ element: e, strategy: st ], [ element: { e, strategy: st } ])
  end

  defp base_jobs_query(), do: from(jobs in Job, as: :job)

  def get_job!(id, params \\ %{})
  def get_job!(id, params) do
    preloads = Map.get(params, :preloads, [])
    base_job_query(id)
    #|> maybe_preload_step_instances(preloads[:step_instances])
    #|> maybe_preload_process_instances(preloads[:process_instances])
    |> maybe_preload_steps(preloads[:steps])
    |> maybe_preload_processes(preloads[:processes])
    |> maybe_preload_last_job_instance(preloads[:last_job_instance])
    |> Repo.one!()
  end

  defp base_job_query(id) do
    from(job in Job, as: :job, where: job.id == ^id)
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

  alias UserDocs.Automation
  def put_blank_job_process_step_instances(%Job{ job_steps: job_steps, job_processes: job_processes } = job) do
    job_steps = Enum.map(job_steps, fn(js) ->
      Map.put(js, :step, Automation.put_blank_step_instance(js.step, nil))
    end)
    job_processes = Enum.map(job_processes, fn(jp) ->
      Map.put(jp, :process, Automation.put_blank_process_and_step_instances(jp.process))
    end)
    job_instance_attrs = %{ status: "not_started", job_id: job.id, name: job.name, order: job.order }
    { :ok, job_instance } = UserDocs.JobInstances.create_job_instance(job_instance_attrs)

    job
    |> Map.put(:job_steps, job_steps)
    |> Map.put(:job_processes, job_processes)
    |> Map.put(:last_job_instance, job_instance)
  end
  def expand_job_process(%Job{} = job, id) when is_integer(id) do
    job_processes =
      Enum.map(job.job_processes,
        fn(job_process) ->
          if (job_process.id == id) do
            collapsed = case job_process.collapsed do
              true -> false
              false -> true
              nil -> true
            end
            attrs = %{ collapsed: collapsed }
            { :ok, updated_job_process } = update_job_process(job_process, attrs)
            updated_job_process
          else
            job_process
          end
        end
      )
    { :ok, Map.put(job, :job_processes, job_processes)}
  end
  def export_job(%Job{} = job) do
    UserDocs.Automation.Runner.parse(job)
  end

  alias UserDocs.Jobs.JobInstance
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.Process

  def prepare_for_execution(%Job{ job_processes: job_processes, job_steps: job_steps } = job) do
    IO.puts("First call")
    job_processes = Enum.map(job_processes,
      fn(jp) ->
        prepare_for_execution(jp)
      end)
    Map.put(job, :job_processes, job_processes)
  end
  def prepare_for_execution(%JobProcess{
    process_instance: %ProcessInstance{ step_instances: step_instances } = process_instance,
    process: %Process{ steps: steps } = process
  } = job_process) when is_list(step_instances) and is_list(steps) do
    _log_string = "Fixing to zip step instances {id, order, step_id}: #{inspect(Enum.map(step_instances, fn(si) -> { si.id, si.order, si.step_id } end))} and steps: #{inspect(Enum.map(steps, fn(s) -> { s.order, s.id } end))}"
    IO.puts(_log_string)
    steps = assign_instances(step_instances, steps)
    process =
      process
      |> Map.put(:steps, steps)
      |> Map.put(:last_process_instance, process_instance)

    Map.put(job_process, :process, process)
  end

  def assign_instances(
    [ %StepInstance{} = step_instance | si_tail ] = step_instances,
    [ %Step{} = step | s_tail ] = steps
  ) do
    step_instance_step_ids = Enum.map(step_instances, fn(si) -> si.step_id end)
    if step.id in step_instance_step_ids do
      step_instance =
        step_instances
        |> Enum.filter(fn(si) -> si.step_id == step.id end)
        |> Enum.at(0)

      [ Map.put(step, :last_step_instance, step_instance) | assign_instances(step_instances, s_tail) ]
    else
      [ step | assign_instances(step_instances, s_tail) ]
    end
  end
  def assign_instances(step_instances, []), do: []
  def assign_instances([], steps), do: steps

  alias UserDocs.Jobs.JobProcess
  def get_executable_items(nil), do: []
  def get_executable_items(%Job{ job_steps: %Ecto.Association.NotLoaded{}} = job) do
    get_job!(job.id, %{ preloads: %{ processes: true, steps: true }})
    |> get_executable_items()
  end
  def get_executable_items(%Job{ job_processes: %Ecto.Association.NotLoaded{}} = job) do
    get_job!(job.id, %{ preloads: %{ processes: true, steps: true }})
    |> get_executable_items()
  end
  def get_executable_items(%Job{ job_steps: job_steps, job_processes: job_processes } = job) do
    job_steps
    ++ job_processes
    |> Enum.sort(fn(o1, o2) -> o1.order < o2.order end)
  end
  def max_order(%Job{ } = job) do
    get_executable_items(job)
    |> max_order()
  end
  def max_order([]), do: 0
  def max_order([ _ | _ ] = items) do
    Enum.reduce(items, 0,
      fn(item, acc) ->
        if item.order > acc do
          item.order
        else
          acc
        end
      end)
  end

  alias UserDocs.Jobs.JobStep

  def get_job_step!(id) do
    from(job_step in JobStep, where: job_step.id == ^id)
    |> Repo.one!()
  end

  def create_job_step(%Job{} = job, step_id) when is_integer(step_id) do
    attrs = %{ job_id: job.id, step_id: step_id, order: max_order(job) + 1 }
    %JobStep{}
    |> JobStep.changeset(attrs)
    |> Repo.insert()
  end

  def update_job_step(%JobStep{} = job_step, attrs) do
    job_step
    |> JobStep.changeset(attrs)
    |> Repo.update()
  end

  def delete_job_step(%JobStep{} = job_step) do
    Repo.delete(job_step)
  end

  alias UserDocs.Jobs.JobProcess

  def get_job_process!(id) do
    from(job_process in JobProcess, where: job_process.id == ^id)
    |> Repo.one!()
  end

  def create_job_process(%Job{} = job, process_id) when is_integer(process_id) do
    attrs = %{ job_id: job.id, process_id: process_id, order: max_order(job) + 1 }
    %JobProcess{}
    |> JobProcess.changeset(attrs)
    |> Repo.insert()
  end

  def update_job_process(%JobProcess{} = job_process, attrs) do
    job_process
    |> JobProcess.changeset(attrs)
    |> Repo.update()
  end

  def delete_job_process(%JobProcess{} = job_process) do
    Repo.delete(job_process)
  end
  """
  Deprecated
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
  """
  """
  Deprecated
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
  """
  """
  # Deprecated
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
"""
"""
# Deprecated
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
"""
"""
Deprecated
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
"""
end
