defmodule UserDocs.ProcessInstances do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.StepInstances
  alias UserDocs.ProcessInstances.ProcessInstance

  def load_user_process_instances(state, opts) do
    user_id = opts[:filters].user_id
    process_instances = list_user_process_instances(user_id)
    StateHandlers.load(state, process_instances, ProcessInstance, opts)
  end

  def list_process_instances(params \\ %{}) do
    _filters = Map.get(params, :filters, [])
    base_process_instances_query()
    |> Repo.all()
  end

  alias UserDocs.Users.User
  def list_user_process_instances(user_id) do
    from(u in User, as: :user)
    |> join(:left, [ user: u ], t in assoc(u, :teams), as: :teams)
    |> join(:left, [ teams: t ], p in assoc(t, :projects), as: :projects)
    |> join(:left, [ projects: p ], v in assoc(p, :versions), as: :versions)
    |> join(:left, [ versions: v ], p in assoc(v, :processes), as: :processes)
    |> join(:inner_lateral, [ processes: p ], pi in subquery(five_process_instances_subquery()), as: :process_instances)
    |> where([user: u], u.id == ^user_id)
    |> select([process_instances: pi], %ProcessInstance{
        id: pi.id, order: pi.order, status: pi.status, name: pi.name, type: pi.type,
        errors: pi.errors, warnings: pi.warnings, process_id: pi.process_id
      })
    |> Repo.all()
  end

  def five_process_instances_subquery() do
    from pi in ProcessInstance, where: parent_as(:processes).id == pi.process_id, limit: 5, order_by: [ desc: pi.id ]
  end

  defp base_process_instances_query(), do: from(process_instances in ProcessInstance)

  def get_process_instance_by_uuid(uuid) do
    uuid_process_instance_query(uuid)
    |> Repo.one!()
  end
  def get_process_instance!(id) do
    base_process_instance_query(id)
    |> Repo.one!()
  end
  def get_process_instance!(id, %{ preloads: "*"}) do
    from(pi in ProcessInstance, as: :process_instance)
    |> where([process_instance: pi], pi.id == ^id)
    |> join(:left, [process_instance: pi], si in assoc(pi, :step_instances), as: :step_instances)
    |> join(:left, [step_instances: si], s in assoc(si, :step), as: :step)
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
        process_instance: process_instance,
        step_instances: step_instances,
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
        step_instances: { step_instances, [
          step: { step, [
            step_type: step_type,
            element: { element, strategy: strategy },
            annotation: { annotation, annotation_type: annotation_type },
            page: page,
            process: process,
            screenshot: screenshot
          ]}
        ]}
      ]
    )
    |> Repo.one!()
  end

  defp base_process_instance_query(id) do
    from(process_instance in ProcessInstance, where: process_instance.id == ^id)
  end

  defp uuid_process_instance_query(uuid) do
    from(process_instances in ProcessInstance, where: process_instances.uuid == ^uuid)
  end

  alias UserDocs.Automation.Process
  alias UserDocs.Jobs.Job
  def create_process_instance_from_job_and_process(%Process{} = process, %Job{} = job, order \\ 0) do
    process_instance = Ecto.build_assoc(job, :process_instances)
    attrs = base_process_instance_attrs(process, step_instance_attrs(process), order)
    create_process_instance(attrs, process_instance)
  end

  def create_process_instance_from_process(process, order) do
    base_process_instance_attrs(process, step_instance_attrs(process), order)
    |> create_process_instance()
  end

  def step_instance_attrs(process) do
    { step_instance_attrs, _max_order } =
      process.steps
      |> Enum.sort(fn(x, y) -> x.order < y.order end)
      |> Enum.reduce({ [], 1 },
        fn(step, { acc, inner_order }) ->
          { [ StepInstances.base_step_instance_attrs(step, inner_order) | acc ], inner_order + 1 }
        end)

    Enum.reverse(step_instance_attrs)
  end

  def base_process_instance_attrs(process, step_instance_attrs, order) do
    %{
      order: order || process.order,
      process_id: process.id,
      step_instances: step_instance_attrs,
      name: process.name,
      attrs: %{},
      status: "not_started",
      errors: [],
      warnings: [],
      type: "process_instance"
    }
  end

  def create_process_instance(attrs) do
    create_process_instance(attrs, %ProcessInstance{ expanded: false })
  end
  def create_process_instance(attrs \\ %{}, %ProcessInstance{} = process_instance) do
    process_instance
    |> ProcessInstance.changeset(attrs)
    |> Repo.insert()
  end

  def update_process_instance(%ProcessInstance{} = process_instance, attrs) do
    process_instance
    |> ProcessInstance.changeset(attrs)
    |> Repo.update()
  end

  def delete_process_instance(%ProcessInstance{} = process_instance) do
    Repo.delete(process_instance)
  end

  def change_process_instance(%ProcessInstance{} = process_instance, attrs \\ %{}) do
    ProcessInstance.changeset(process_instance, attrs)
  end

  def process_instances_status([]), do: :none
  def process_instances_status([ %ProcessInstance{ status: "failed" } | _ ]), do: :fail
  def process_instances_status([ %ProcessInstance{ status: "started" } | _ ]), do: :started
  def process_instances_status([ %ProcessInstance{ status: "not_started" } | _ ]), do: :warn
  def process_instances_status([ %ProcessInstance{ status: "warn" } | _ ]), do: :warn
  def process_instances_status([ %ProcessInstance{ status: "complete" } | rest ]) do
    rest
    |> status_counts()
    |> rest_status()
  end

  def rest_status(%{ failed: 0, started: _, not_started: _, warn: 0, complete: _ }), do: :ok
  def rest_status(_), do: :warn

  def status_counts(process_instances) when is_list(process_instances) do
    %{
      failed: count_status(process_instances, "failed"),
      started: count_status(process_instances, "started"),
      not_started: count_status(process_instances, "not_started"),
      warn: count_status(process_instances, "warn"),
      complete: count_status(process_instances, "complete")
    }
  end

  def count_status([ %ProcessInstance{} | _ ] = process_instances, status) do
    Enum.count(process_instances, fn(pi) -> pi.status == status end)
  end
  def count_status([ ], _), do: 0
end

"""
  def format_process_instance_for_export(%ProcessInstance{} = process_instance) do
    start_attrs = %{
      order: 0,
      status: "not_started",
      name: "Start Process " <> process_instance.name,
      attrs: %{
        step_type: %{
          name: "Start Process"
        },
        step: %{
          process: %{
            id: process_instance.process_id
          }
        }
      },
      errors: [],
      warnings: [],
    }

    complete_attrs = %{
      order: 0,
      status: "not_started",
      name: "Complete Process " <> process_instance.name,
      attrs: %{
        step_type: %{
          name: "Complete Process"
        },
        step: %{
          process: %{
            id: process_instance.process_id
          }
        }
      },
      errors: [],
      warnings: [],
    }

    [ start_attrs ]
    ++ Enum.map(process_instance.step_instances, &StepInstances.format_step_instance_for_export/1)
    ++ [ complete_attrs ]
  end

    def toggle_process_instance_expanded(%ProcessInstance{ expanded: nil } = process_instance) do
      update_process_instance(process_instance, %{ expanded: true })
    end
    def toggle_process_instance_expanded(%ProcessInstance{} = process_instance) do
      update_process_instance(process_instance, %{ expanded: not process_instance.expanded })
    end

"""
