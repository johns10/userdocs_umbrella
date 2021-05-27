defmodule UserDocs.AutomationManager do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Automation.Process
  alias UserDocs.Automation.Step
  alias UserDocs.ProcessInstances.ProcessInstance

  def get_step!(id) do
    from(s in Step, as: :steps)
    |> where([steps: s], s.id == ^id)
    |> get_step_joins()
    |> get_step_preloads()
    |> Repo.one()
  end

  def get_step_joins(query) do
    query
    |> join(:left, [steps: s], st in assoc(s, :step_type), as: :step_type)
    |> join(:left, [steps: s], a in assoc(s, :annotation), as: :annotation)
    |> join(:left, [steps: s], p in assoc(s, :page), as: :page)
    |> join(:left, [steps: s], e in assoc(s, :element), as: :element)
    |> join(:left, [steps: s], sc in assoc(s, :screenshot), as: :screenshot)
    |> join(:left, [steps: s], pr in assoc(s, :process), as: :process)
    |> join(:left, [steps: s], si in assoc(s, :step_instances), as: :last_step_instance)
    |> order_by([last_step_instance: si], desc: si.id)
    |> limit([last_step_instance: si], 1)
    |> join(:left, [element: e], st in assoc(e, :strategy), as: :strategy)
    |> join(:left, [annotation: a ], at in assoc(a, :annotation_type), as: :annotation_type)
  end

  def get_step_preloads(query) do
    query
    |> preload([ step_type: step_type ], [ step_type: step_type ])
    |> preload([ annotation: annotation ], [ annotation: annotation ])
    |> preload([ page: page ], [ page: page ])
    |> preload([ element: element ], [ element: element ])
    |> preload([ screenshot: screenshot ], [ screenshot: screenshot ])
    |> preload([ process: process ], [ process: process ])
    |> preload([ last_step_instance: lsi ], [ last_step_instance: lsi ])
    |> preload([ annotation: a, annotation_type: at ], [ annotation: { a, annotation_type: at } ])
    |> preload([ element: e, strategy: st ], [ element: { e, strategy: st } ])
  end

  def get_process!(id) do
    from(p in Process, as: :process)
    |> where([process: p], p.id == ^id)
    |> join(:left, [process: p], s in assoc(p, :steps), as: :steps)
    |> order_by([steps: s], asc: s.order)
    |> join(:left, [steps: s], st in assoc(s, :step_type), as: :step_type)
    |> join(:left, [steps: s], a in assoc(s, :annotation), as: :annotation)
    |> join(:left, [steps: s], p in assoc(s, :page), as: :page)
    |> join(:left, [steps: s], e in assoc(s, :element), as: :element)
    |> join(:left, [steps: s], sc in assoc(s, :screenshot), as: :screenshot)
    |> join(:left, [steps: s, element: e], st in assoc(e, :strategy), as: :strategy)
    |> join(:left, [steps: s, annotation: a ], at in assoc(a, :annotation_type), as: :annotation_type)
    |> join(:left, [ process: p ], pi in assoc(p, :process_instances), as: :process_instances)
    |> preload([ steps: s ], [ steps: s])
    |> preload([ steps: s, step_type: st ], [ steps: { s, step_type: st } ])
    |> preload([ steps: s, screenshot: sc ], [ steps: { s, screenshot: sc } ])
    |> preload([ steps: s, page: page ], [ steps: { s, page: page } ])
    |> preload([ steps: s, element: element ], [ steps: { s, element: element } ])
    |> preload([ process: p, steps: s, element: element ], [ steps: { s, process: p } ])
    |> preload([ steps: s, annotation: annotation ], [ steps: { s, annotation: annotation } ])
    |> preload([ steps: s, annotation: a, annotation_type: at ], [ steps: { s, annotation: { a, annotation_type: at} } ])
    |> preload([ steps: s, element: e, strategy: st ], [ steps: { s, element: { e, strategy: st} } ])
    |> preload([ last_process_instance: lpi ], [ last_process_instance: ^get_last_process_instance() ])
    |> Repo.one()
  end

  def get_last_process_instance() do
    from(pi in ProcessInstance, as: :process_instances)
    |> order_by([ process_instances: pi ], desc: pi.id)
    |> limit([ process_instances: pi ], 1)
  end
end
