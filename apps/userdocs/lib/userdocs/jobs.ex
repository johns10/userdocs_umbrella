defmodule UserDocs.Jobs do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Jobs.StepInstance

  def create_step_instance_from_step(step, order) do
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

  def create_step_instance(attrs \\ %{}) do
    %StepInstance{ step: nil }
    |> StepInstance.changeset(attrs)
    |> IO.inspect()
    |> Ecto.Changeset.put_change(:id, UUID.uuid4())
    |> Ecto.Changeset.apply_action(:insert)
  end

  def update_step_instance(%StepInstance{} = step_instance, attrs) do
    step_instance
    |> StepInstance.changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  def format_step_instance_for_export(%StepInstance{} = step_instance) do
    step_instance
    |> Map.put(:attrs, UserDocs.Automation.Runner.parse(step_instance.step))
    |> Map.take(StepInstance.__schema__(:fields))
    |> Map.put(:type, StepInstance |> to_string() |> String.split(".") |> Enum.at(-1))
  end

  alias UserDocs.Jobs.ProcessInstance

  def create_process_instance(attrs \\ %{}) do
    %ProcessInstance{ process: nil, step_instances: nil, expanded: false }
    |> ProcessInstance.changeset(attrs)
    |> Ecto.Changeset.put_change(:id, UUID.uuid4())
    |> Ecto.Changeset.apply_action(:insert)
  end

  def toggle_process_instance_expanded(%ProcessInstance{} = process_instance) do
    attrs = %{ expanded: not process_instance.expanded }
    update_process_instance(process_instance, attrs)
  end

  def update_process_instance(%ProcessInstance{} = process_instance, attrs) do
    process_instance
    |> ProcessInstance.changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

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
    ++ Enum.map(process_instance.step_instances, &format_step_instance_for_export/1)
    ++ [ complete_attrs ]
  end

  #

  def create_process_instance_from_process(process, order) do
    { step_instance_attrs, _max_order } =
      process.steps
      |> Enum.sort(fn(x, y) -> x.order < y.order end)
      |> Enum.reduce({ [], 1 },
        fn(step, { acc, inner_order }) ->
          { [ base_step_instance_attrs(step, inner_order) | acc ], inner_order + 1 }
        end)

    step_instance_attrs = Enum.reverse(step_instance_attrs)

    base_process_instance_attrs(process, step_instance_attrs, order)
    |> create_process_instance()
  end

  def base_process_instance_attrs(process, step_instance_attrs, order) do
    %{
      order: order,
      process_id: process.id,
      process: process,
      step_instances: step_instance_attrs,
      name: process.name,
      attrs: %{},
      status: "not_started",
      errors: [],
      warnings: []
    }
  end

  def format_instance(%StepInstance{} = step_instance), do: format_step_instance_for_export(step_instance)
  def format_instance(%ProcessInstance{} = process_instance), do: format_process_instance_for_export(process_instance)

  alias UserDocs.Jobs.Job

  def create_job(attrs \\ %{}) do
    %Job{ process_instances: [], step_instances: []}
    |> Job.changeset(attrs)
    |> Ecto.Changeset.apply_action(:insert)
  end

  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  def expand_process_instance(%Job{} = job, id) do
    Ecto.Changeset.change(job, %{})
    process_instances =
      Enum.map(job.process_instances,
        fn(process_instance) ->
          if (process_instance.id == id) do
            { :ok, updated_process_instance } =
              toggle_process_instance_expanded(process_instance)

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
