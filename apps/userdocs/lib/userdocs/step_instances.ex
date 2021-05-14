defmodule UserDocs.StepInstances do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.StepInstances.StepInstance

  def load_step_instances(state, opts) do
    StateHandlers.load(state, list_step_instances(opts[:params]), StepInstance, opts)
  end

  def list_step_instances(params \\ %{}) do
    filters = Map.get(params, :filters, [])
    base_step_instances_query()
    |> maybe_filter_step_instances_by_version_id(filters[:process_id])
    |> Repo.all()
  end

  def maybe_filter_step_instances_by_version_id(query, nil), do: query
  def maybe_filter_step_instances_by_version_id(query, version_id) do
    from(step_instance in query,
      left_join: step in assoc(step_instance, :step),
      left_join: process in assoc(step, :process),
      where: process.version_id == ^version_id
    )
  end

  defp base_step_instances_query(), do: from(step_instances in StepInstance)

  def get_step_instance!(id) do
    base_step_instance_query(id)
    |> Repo.one!()
  end

  def get_step_instance!(id, %{ preloads: "*"}) do
    from(si in StepInstance, as: :step_instance)
    |> where([step_instance: si], si.id == ^id)
    |> join(:left, [step_instance: si], s in assoc(si, :step), as: :step)
    |> join(:left, [step: s], st in assoc(s, :step_type), as: :step_type)
    |> join(:left, [step: s], a in assoc(s, :annotation), as: :annotation)
    |> join(:left, [step: s], p in assoc(s, :page), as: :page)
    |> join(:left, [step: s], e in assoc(s, :element), as: :element)
    |> join(:left, [step: s], s in assoc(s, :screenshot), as: :screenshot)
    |> join(:left, [step: s], pr in assoc(s, :process), as: :process)
    |> join(:left, [element: e], st in assoc(e, :strategy), as: :strategy)
    |> join(:left, [annotation: a], at in assoc(a, :annotation_type), as: :annotation_type)
    |> preload(
      [
        step_instance: step_instance,
        step: step,
        step_type: step_type,
        element: element,
        strategy: strategy,
        annotation: annotation,
        annotation_type: annotation_type,
        page: page,
        process: process,
        screenshot: screenshot
      ],
      [
        step: { step, [
          step_type: step_type,
          element: { element, strategy: strategy },
          annotation: { annotation, annotation_type: annotation_type },
          page: page,
          process: process,
          screenshot: screenshot
        ]}
      ]
    )
    |> Repo.one!()
  end

  defp base_step_instance_query(id) do
    from(step_instance in StepInstance, where: step_instance.id == ^id)
  end

  alias UserDocs.Jobs.Job
  alias UserDocs.Automation.Step

  def create_step_instance_from_job_and_step(%Step{} = step, %Job{} = job, order \\ 0) do
    step_instance = Ecto.build_assoc(job, :step_instances)
    attrs = base_step_instance_attrs(step, order)
    create_step_instance(attrs, step_instance)
  end

  def create_step_instance_from_step(step, order \\ 0) do
    attrs = base_step_instance_attrs(step, order)
    create_step_instance(attrs)
  end

  def base_step_instance_attrs(step, order) do
    %{
      order: order,
      step_id: step.id,
      name: step.name,
      step: step,
      attrs: %{},
      status: "not_started",
      errors: [],
      warnings: []
    }
  end

  def create_step_instance(attrs) do
    create_step_instance(attrs, %StepInstance{})
  end

  def create_step_instance(attrs, %StepInstance{} = step_instance) do
    step_instance
    |> StepInstance.changeset(attrs)
    |> Repo.insert()
  end

  def update_step_instance(%StepInstance{} = step_instance, attrs) do
    step_instance
    |> StepInstance.changeset(attrs)
    |> Repo.update()
  end

  def format_step_instance_for_export(%StepInstance{} = step_instance) do
    step_instance
    |> Map.put(:attrs, UserDocs.Automation.Runner.parse(step_instance.step))
    |> Map.take(StepInstance.__schema__(:fields))
    |> Map.put(:type, StepInstance |> to_string() |> String.split(".") |> Enum.at(-1))
  end

  def delete_step_instance(%StepInstance{} = step_instance) do
    Repo.delete(step_instance)
  end

  def change_step_instance(%StepInstance{} = step_instance, attrs \\ %{}) do
    StepInstance.changeset(step_instance, attrs)
  end
end
