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
    |> join(:left, [processes: p], step in assoc(p, :steps), as: :jp_steps)
    |> order_by([jp_steps: s], asc: s.order)
    |> join(:left, [jp_steps: s], st in assoc(s, :step_type), as: :jp_step_type)
    |> join(:left, [jp_steps: s], a in assoc(s, :annotation), as: :jp_annotation)
    |> join(:left, [jp_steps: s], p in assoc(s, :page), as: :jp_page)
    |> join(:left, [jp_steps: s], e in assoc(s, :element), as: :jp_element)
    |> join(:left, [jp_steps: s], pr in assoc(s, :screenshot), as: :jp_screenshot)
    |> join(:left, [jp_steps: s], pr in assoc(s, :process), as: :jp_process)
    |> join(:left, [jp_element: e], st in assoc(e, :strategy), as: :jp_strategy)
    |> join(:left, [jp_annotation: a ], at in assoc(a, :annotation_type), as: :jp_annotation_type)
    |> preload([ job_processes: jp, processes: p, jp_steps: s, jp_step_type: st, jp_element: e, jp_strategy: strategy,
        jp_annotation: a, jp_annotation_type: at, jp_page: page, jp_process: process, jp_screenshot: screenshot ],
      [ job_processes: { jp,
          process: { p, [
            steps: { s, [
              step_type: st,
              element: { e, strategy: strategy },
              annotation: { a, annotation_type: at },
              page: page,
              process: process,
              screenshot: screenshot ]} ]} } ])
  end

  defp maybe_preload_last_job_instance(query, nil), do: query
  defp maybe_preload_last_job_instance(query, _) do
    from(job in query, preload: [ last_job_instance: ^preload_last_job_instance_query() ])
  end

  defp preload_last_job_instance_query() do
    from(job_instance in UserDocs.Jobs.JobInstance, as: :job_instance)
    |> order_by([ job_instance: ji], desc: ji.id)
    |> limit([ job_instance: ji ], 1)
    |> preload([ step_instances: ^preload_step_instances_query(), process_instances: ^preload_process_instances_query ])
  end

  defp preload_process_instances_query() do
    from(process_instances in UserDocs.ProcessInstances.ProcessInstance, as: :process_instances)
    |> order_by([ process_instances: pi], asc: pi.order)
    |> preload([ step_instances: ^preload_step_instances_query() ])
  end

  defp preload_step_instances_query() do
    from(step_instances in UserDocs.StepInstances.StepInstance, as: :step_instances)
    |> order_by([ step_instances: si], asc: si.order)
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
"""
  #TODO: Revise
  def update_job_step(
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

  #TODO: Revise
  def update_job_step_instance(
    %Job{ step_instances: step_instances } = job,
    %{ "id" => id } = step_instance_attrs
  ) do
    updated_step_instances = update_this_step_instance(step_instances, id, step_instance_attrs)
    { :ok, Map.put(job, :step_instances, updated_step_instances)}
  end

  #TODO: Revise
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
"""
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
  def prepare_for_execution(
    %Job{ job_processes: job_processes, job_steps: job_steps, last_job_instance:
      %JobInstance{ process_instances: process_instances, step_instances: step_instances } = job_instance } = job
  ) do
    log_string = "
      Preparing a job for execution.  There are #{Enum.count(job_processes)} processes on the job.  There are
      #{Enum.count(process_instances)} process instances on the job instance.  If those don't match, there will
      be some new process instances created.  Similarly, there are #{Enum.count(job_steps)} job steps on the job.
      There are #{Enum.count(step_instances)} on the job.  If those don't match, there will be some new step instances
      created.
    "
    """
    Logger.info(log_string)
    job_processes = zip_job_processes([], job_processes, process_instances, job_instance.id)
    job_steps = zip_job_steps([], job_steps, step_instances)

    job
    |> Map.put(:job_processes, job_processes)
    |> Map.put(:job_steps, job_steps)
    """
    Enum.each(job_processes, fn(jp) -> IO.inspect(jp) end)
    job
  end
  def prepare_for_execution(%Job{ last_job_instance: nil } = job), do: job
  alias UserDocs.Jobs.JobProcess
  def zip_job_processes(result,
    [ %JobProcess{} = job_process | job_processes_tail ] = job_processes,
    [ %ProcessInstance{} = process_instance | process_instances_tail ] = process_instances,
    job_instance_id
  ) do
    #IO.inspect("zip_job_processes list")
    case job_process.process.id == process_instance.process_id do
      false ->
        #IO.inspect("zip_job_processes list false")
        tail = zip_job_processes(result, job_processes_tail, process_instances, job_instance_id)
        [ put_new_process_instance(job_process, job_instance_id) | tail ]
      true ->
        #IO.inspect("zip_job_processes list true")
        tail = zip_job_processes(result, job_processes_tail, process_instances_tail, job_instance_id)
        [ match_job_process(job_process, process_instance ) | tail ]
    end
  end
  def zip_job_processes(result,
    [ %JobProcess{} = job_process ],
    [ %ProcessInstance{} = process_instance ],
    job_instance_id
  ) do
    #IO.inspect("zip_job_processes single")
    case job_process.process.id == process_instance.process_id do
      false -> raise("Last processes don't match in zip_job_processes")
      true -> [ match_job_process(job_process, process_instance ) | result ]
    end
  end
  def zip_job_processes(result,
    [] = job_processes,
    [ %ProcessInstance{} = process_instance| process_instances_tail ],
    job_instance_id
  ) do
    #IO.inspect("zip_job_processes extra process instances")
    tail = zip_job_processes(result, job_processes, process_instances_tail, job_instance_id)
    { :ok, _ } = delete_process_instance(process_instance)
    tail
  end
  def zip_job_processes(result,
    [],
    [ %ProcessInstance{} = process_instance ],
    job_instance_id
  ) do
    #IO.inspect("zip_job_processes extra process instances")
    { :ok, _ } = delete_process_instance(process_instance)
    result
  end
  def zip_job_processes(result,
    [ %JobProcess{} = job_process | job_processes_tail ],
    [] = process_instances, job_instance_id
  ) do
    #IO.inspect("zip_job_processes extra process")
    tail = zip_job_processes(result, job_processes_tail, process_instances, job_instance_id)
    [ put_new_process_instance(job_process, job_instance_id) | tail ]
  end
  def zip_job_processes(result, [], [], job_instance_id) do
    result
  end

  def put_new_process_instance(%JobProcess{} = job_process, job_instance_id) do
    IO.puts("put_new_process_instance")
    attrs = %{
      status: "not_started", process_id: job_process.process.id,
      name: job_process.process.name, order: job_process.process.order,
      job_instance_id: job_instance_id
    }
    { :ok, new_process_instance } = ProcessInstances.create_process_instance(attrs)
    new_process_instance = Map.put(new_process_instance, :step_instances, [])
    steps = zip_steps([], job_process.process.steps, new_process_instance.step_instances, new_process_instance.id)
    process = Map.put(job_process.process, :last_process_instance, new_process_instance)
    Map.put(job_process, :process, process)
  end

  def match_job_process(%JobProcess{} = job_process, %ProcessInstance{} = process_instance) do
    log_string = "
      Matching Job Process.  Next we'll handle the steps.  This process has #{Enum.count(job_process.process.steps)} steps and
      #{Enum.count(process_instance.step_instances)} step instances
    "
    Logger.info(log_string)
    steps = zip_steps([], job_process.process.steps, process_instance.step_instances)
    process =
      job_process.process
      |> Map.put(:last_process_instance, process_instance)
      |> Map.put(:steps, steps)

    Map.put(job_process, :process, process)
  end

  def delete_process_instance(%ProcessInstance{ step_instances: step_instances } = process_instance) do
    Enum.each(step_instances,
      fn(si) ->
        { :ok, _ } = UserDocs.StepInstances.delete_step_instance(si)
      end)
    UserDocs.ProcessInstances.delete_process_instance(process_instance)
  end

  def zip_job_steps(result,
  [ %JobStep{} = job_step | job_steps_tail ] = steps,
  [ %StepInstance{} = step_instance | step_instances_tail ] = step_instances
  ) do
    case job_step.step.id == step_instance.step_id do
      false ->
        tail = zip_job_steps(result, job_steps_tail, step_instances)
        job_step = Map.put(job_step, :step, Automation.put_blank_step_instance(job_step.step))
        [ job_step | tail ]
      true ->
        tail = zip_job_steps(result, job_steps_tail, step_instances_tail)
        job_step = Map.put(job_step, :step, match_step(job_step.step, step_instance))
        [ job_step | tail ]
    end
  end
  def zip_job_steps(result,
    [ %JobStep{} = job_step ] = steps,
    [ %StepInstance{} = step_instance ] = step_instances
  ) do
    case job_step.step.id == step_instance.step_id do
      false -> raise("Steps don't match, failing")
      true -> Map.put(job_step, :step, match_step(job_step.step, step_instance))
    end
  end
  def zip_job_steps(result, [], [ %StepInstance{} = step_instance ]) do
    { :ok, _ } = UserDocs.StepInstances.delete_step_instance(step_instance)
    result
  end
  def zip_job_steps(result, [], []) do
    result
  end

  def zip_steps(result, steps, step_instances, process_instance_id \\ nil)
  def zip_steps(result,
    [ %Step{} = step | steps_tail ] = steps,
    [ %StepInstance{} = step_instance | step_instances_tail ] = step_instances,
    process_instance_id
  ) do
    case step.id == step_instance.step_id do
      false ->
        Logger.warn("We failed to match step/step_instances. Id's: #{step.id}/#{step_instance.step_id}, orders: #{step.order}/#{step_instance.order}")
        tail = zip_steps(result, steps_tail, step_instances)
        [ Automation.put_blank_step_instance(step, process_instance_id) | tail ]
      true ->
        tail = zip_steps(result, steps_tail, step_instances_tail, process_instance_id)
        [ match_step(step, step_instance) | tail ]
    end
  end
  def zip_steps(result,
    [ %Step{} = step ] = steps,
    [ %StepInstance{} = step_instance ] = step_instances,
    process_instance_id
  ) do
    case step.id == step_instance.step_id do
      false -> raise("Steps don't match, failing")
      true -> match_step(step, step_instance)
    end
  end
  def zip_steps(result,
    [ %Step{} = step | steps_tail ],
    [] = step_instances,
    process_instance_id
  ) do
    #IO.inspect("zip_steps extra steps")
    tail = zip_steps(result, steps_tail, step_instances, process_instance_id)
    step = Automation.put_blank_step_instance(step, process_instance_id)
    [ step | tail ]
  end
  def zip_steps(result, [ %Step{} = step ], [] = step_instances, process_instance_id) do
    #IO.inspect("zip_steps last extra step")
    [ Automation.put_blank_step_instance(step, process_instance_id) | result ]
  end
  def zip_steps(result, [], [], process_instance_id) do
    result
  end

  def match_step(%Step{} = step, step_instance) do
    Map.put(step, :last_step_instance, step_instance)
  end

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
