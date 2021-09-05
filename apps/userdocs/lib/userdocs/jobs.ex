defmodule UserDocs.Jobs do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.ProcessInstances.ProcessInstance

  alias UserDocs.StepInstances
  alias UserDocs.StepInstances.StepInstance

  alias UserDocs.Automation.Step

  alias UserDocs.Jobs.Job
  alias UserDocs.Jobs.JobStep

  def list_jobs(params \\ %{}) do
    filters = Map.get(params, :filters, [])
    _preloads = Map.get(params, :preloads, [])
    base_jobs_query()
    #|> maybe_preload_step_instances(preloads[:step_instances])
    #|> maybe_preload_process_instances(preloads[:process_instances])
    |> maybe_filter_by_team_id(filters[:team_id])
    |> Repo.all()
  end

  defp maybe_filter_by_team_id(query, nil), do: query
  defp maybe_filter_by_team_id(query, team_id) do
    from(job in query, where: job.team_id == ^team_id)
  end

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
    |> join(:left, [js_page: p], project in assoc(p, :project), as: :js_project)
    |> join(:left, [js_steps: s], e in assoc(s, :element), as: :js_element)
    |> join(:left, [js_steps: s], pr in assoc(s, :screenshot), as: :js_screenshot)
    |> join(:left, [js_steps: s], pr in assoc(s, :process), as: :js_process)
    |> join(:left, [js_element: e], st in assoc(e, :strategy), as: :js_strategy)
    |> join(:left, [js_annotation: a], at in assoc(a, :annotation_type), as: :js_annotation_type)
    |> preload([job_steps: js, js_steps: s, js_step_type: st, js_element: e, js_strategy: strategy, js_annotation: a,
        js_annotation_type: at, js_page: page, js_process: process, js_screenshot: screenshot, js_step_instances: si,
        js_project: project],
      [job_steps: {js,
          step_instance: si,
          step: {s, [
            step_type: st,
            element: {e, strategy: strategy},
            annotation: {a, annotation_type: at},
            page: {page, project: project},
            process: process,
            screenshot: screenshot]}}])
  end

  defp maybe_preload_processes(query, nil), do: query
  defp maybe_preload_processes(query, _) do
    from(jobs in query)
    |> join(:left, [job: j], jp in assoc(j, :job_processes), as: :job_processes)
    |> join(:left, [job_processes: jp], jp in assoc(jp, :process), as: :processes)
    |> order_by([job_processes: jp], asc: jp.order)
    |> preload([job_processes: jp, processes: p],
      [job_processes: {jp,
        process_instance: ^preload_process_instance(),
        process: {p, [
          steps: ^preload_steps_query()
      ]}}])
  end

  defp maybe_preload_last_job_instance(query, nil), do: query
  defp maybe_preload_last_job_instance(query, _) do
    from(job in query, preload: [last_job_instance: ^preload_last_job_instance_query()])
  end

  defp preload_process_instance() do
    from(process_instance in UserDocs.ProcessInstances.ProcessInstance)
    |> order_by(asc: :order)
    |> preload([step_instances: ^preload_step_instances_query()])
  end

  defp preload_last_job_instance_query() do
    from(job_instance in UserDocs.Jobs.JobInstance)
    |> order_by(desc: :id)
    |> limit(1)
    |> preload([
      step_instances: ^preload_step_instances_query(),
      process_instances: ^preload_process_instances_query()
    ])
  end

  defp preload_process_instances_query() do
    from(process_instances in UserDocs.ProcessInstances.ProcessInstance)
    |> order_by(asc: :order)
    |> preload([step_instances: ^preload_step_instances_query()])
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
    |> join(:left, [page: p], project in assoc(p, :project), as: :project)
    |> join(:left, [steps: s], e in assoc(s, :element), as: :element)
    |> join(:left, [steps: s], sc in assoc(s, :screenshot), as: :screenshot)
    |> join(:left, [steps: s], pr in assoc(s, :process), as: :process)
    |> join(:left, [element: e], st in assoc(e, :strategy), as: :strategy)
    |> join(:left, [annotation: a], at in assoc(a, :annotation_type), as: :annotation_type)
    |> preload([step_type: step_type], [step_type: step_type])
    |> preload([annotation: annotation], [annotation: annotation])
    |> preload([page: page, project: project], [page: {page, project: project}])
    |> preload([element: element], [element: element])
    |> preload([screenshot: screenshot], [screenshot: screenshot])
    |> preload([process: process], [process: process])
    |> preload([annotation: a, annotation_type: at], [annotation: {a, annotation_type: at}])
    |> preload([element: e, strategy: st], [element: {e, strategy: st}])
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
            attrs = %{collapsed: collapsed}
           {:ok, updated_job_process} = update_job_process(job_process, attrs)
            updated_job_process
          else
            job_process
          end
        end
      )
   {:ok, Map.put(job, :job_processes, job_processes)}
  end

  alias UserDocs.Jobs.JobProcess
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.Process

  alias UserDocs.Jobs.JobProcess
  def get_executable_items(nil), do: []
  def get_executable_items(%Job{job_steps: job_steps, job_processes: job_processes}) do
    job_steps
    ++ job_processes
    |> Enum.sort(fn(o1, o2) -> o1.order < o2.order end)
  end

  def max_order(%Job{} = job) do
    get_executable_items(job)
    |> max_order()
  end
  def max_order([]), do: 0
  def max_order([_ | _] = items) do
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

  def create_job_step(%Job{} = job, step_id, step_instance_id \\ nil) when is_integer(step_id) do
    attrs = %{
      job_id: job.id,
      step_id: step_id,
      order: max_order(job) + 1,
      step_instance_id: step_instance_id
    }
    %JobStep{}
    |> JobStep.changeset(attrs)
    |> Repo.insert()
  end

  def update_job_step(%JobStep{} = job_step, attrs) do
    job_step
    |> JobStep.changeset(attrs)
    |> Repo.update()
  end

  def update_job_process(%Job{job_processes: job_processes} = job, %ProcessInstance{id: id} = process_instance) do
    updated_job_processes =
      Enum.map(job_processes,
        fn(jp) ->
          case jp.process_instance_id == id do
            true ->
              Map.put(jp, :process_instance, process_instance)
            false -> jp
          end
        end)

    Map.put(job, :job_processes, updated_job_processes)
  end

  def update_job_step_instance(%Job{} = job, %StepInstance{id: _id} = step_instance) do
    job
    |> update_job_direct_step_instance(step_instance)
    |> update_job_process_instance_step_instance(step_instance)
  end

  def update_job_direct_step_instance(%Job{job_steps: []} = job, %StepInstance{}), do: job
  def update_job_direct_step_instance(%Job{job_steps: job_steps} = job, %StepInstance{id: id} = step_instance) do
    job_steps =
      Enum.map(job_steps,
        fn(job_step) ->
          case job_step.step_instance_id == id do
            true -> Map.put(job_step, :step_instance, step_instance)
            false -> job_step
          end
        end)

    Map.put(job, :job_steps, job_steps)
  end


  def update_job_process_instance_step_instance(%Job{job_processes: []} = job, %StepInstance{}), do: job
  def update_job_process_instance_step_instance(
    %Job{job_processes: job_processes} = job,
    %StepInstance{id: id, process_instance_id: process_instance_id, step_id: _} = step_instance
  ) do
    _log_string = "updating job step instance #{step_instance.id} inside process instance with id #{process_instance_id}"
    job_processes =
      Enum.map(job_processes,
        fn(job_process) ->
          case job_process.process_instance_id == process_instance_id do
            true ->
              steps = replace_matching_step_instance(job_process.process.steps, step_instance)
              process = Map.put(job_process.process, :steps, steps)
              Map.put(job_process, :process, process)
            false -> job_process
          end
        end)

    Map.put(job, :job_processes, job_processes)
  end

  def replace_matching_step_instance(steps, step_instance) do
    Enum.map(steps,
      fn(step) ->
        case step.id == step_instance.step_id do
          true -> Map.put(step, :last_step_instance, step_instance)
          false -> step
        end
      end)
  end

  def delete_job_step(%JobStep{} = job_step) do
    Repo.delete(job_step)
  end

  alias UserDocs.Jobs.JobProcess

  def get_job_process!(id) do
    from(job_process in JobProcess, where: job_process.id == ^id)
    |> Repo.one!()
  end

  def create_job_process(%Job{} = job, process_id, process_instance_id \\ nil) when is_integer(process_id) do
    attrs = %{
      job_id: job.id,
      process_id: process_id,
      order: max_order(job) + 1,
      process_instance_id: process_instance_id
    }

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

  def fetch_step_from_job_processes(%Job{} = job, process_instance_id, step_instance_id) do
    try do
      job.job_processes
      |> Enum.filter(fn(jp) -> jp.process_instance_id == process_instance_id end)
      |> Enum.at(0)
      |> Map.get(:process)
      |> Map.get(:steps)
      |> Enum.filter(fn(s) -> s.last_step_instance.id == step_instance_id end)
      |> Enum.at(0)
    rescue
      e in BadMapError ->
        Logger.error(e)
        nil
    end
  end

  def fetch_step_from_job_step(%Job{} = job, step_instance_id) do
    try do
      job.job_steps
      |> Enum.filter(fn(js) -> js. step_instance_id == step_instance_id end)
      |> Enum.at(0)
      |> Map.get(:step)
    rescue
      e in BadMapError ->
        Logger.error(e)
        nil
    end
  end
end
