defmodule UserDocs.AutomationManager do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Automation.Process
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.StepType
  alias UserDocs.Web.Strategy
  alias UserDocs.Web.Annotation
  alias UserDocs.Web.AnnotationType
  alias UserDocs.Web.Page
  alias UserDocs.Web.Element

  def get_step!(id) do
    from(s in Step, as: :steps)
    |> where([steps: s], s.id == ^id)
    |> get_step_joins()
    |> get_step_preloads()
    |> Repo.one()
  end

  def get_step_joins(query) do
    query
    |> join(:left, [steps: s], st in StepType, on: s.step_type_id == st.id, as: :step_type)
    |> join(:left, [steps: s], a in Annotation, on: s.annotation_id == a.id, as: :annotation)
    |> join(:left, [steps: s], p in Page, on: s.page_id == p.id, as: :page)
    |> join(:left, [steps: s], e in Element, on: s.element_id == e.id, as: :element)
    |> join(:left, [steps: s], pr in assoc(s, :screenshot), as: :screenshot)
    |> join(:left, [steps: s], pr in Process, on: s.process_id == pr.id, as: :process)
    |> join(:left, [element: e], st in Strategy, on: e.strategy_id == st.id, as: :strategy)
    |> join(:left, [annotation: a ], at in AnnotationType, on: a.annotation_type_id == at.id, as: :annotation_type)
  end

  def get_step_preloads(query) do
    query
    |> preload([ step_type: step_type ], [ step_type: step_type ])
    |> preload([ annotation: annotation ], [ annotation: annotation ])
    |> preload([ page: page ], [ page: page ])
    |> preload([ element: element ], [ element: element ])
    |> preload([ screenshot: screenshot ], [ screenshot: screenshot ])
    |> preload([ process: process ], [ process: process ])
    |> preload([ annotation: a, annotation_type: at ], [ annotation: { a, annotation_type: at } ])
    |> preload([ element: e, strategy: st ], [ element: { e, strategy: st } ])
  end

  def get_process!(id) do
    Process
    |> where([p], p.id == ^id)
    |> join(:left, [p], s in Step, on: s.process_id == p.id, as: :steps)
    |> join(:left, [steps: s], st in StepType, on: s.step_type_id == st.id, as: :step_type)
    |> join(:left, [steps: s], a in Annotation, on: s.annotation_id == a.id, as: :annotation)
    |> join(:left, [steps: s], p in Page, on: s.page_id == p.id, as: :page)
    |> join(:left, [steps: s], e in Element, on: s.element_id == e.id, as: :element)
    |> join(:left, [steps: s, element: e], st in Strategy, on: e.strategy_id == st.id, as: :strategy)
    |> join(:left, [steps: s, annotation: a ], at in AnnotationType, on: a.annotation_type_id == at.id, as: :annotation_type)
    |> preload([ p, steps: s ], [ steps: s])
    |> preload([ p, steps: s, step_type: step_type ], [ steps: { s, step_type: step_type } ])
    |> preload([ p, steps: s, page: page ], [ steps: { s, page: page } ])
    |> preload([ p, steps: s, element: element ], [ steps: { s, element: element } ])
    |> preload([ p, steps: s, element: element ], [ steps: { s, process: p } ])
    |> preload([ p, steps: s, annotation: annotation ], [ steps: { s, annotation: annotation } ])
    |> preload([ p, steps: s, annotation: a, annotation_type: at ], [ steps: { s, annotation: { a, annotation_type: at} } ])
    |> preload([ p, steps: s, element: e, strategy: st ], [ steps: { s, element: { e, strategy: st} } ])
    |> Repo.one()
  end
end
