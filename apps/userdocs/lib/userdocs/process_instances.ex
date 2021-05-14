defmodule UserDocs.ProcessInstances do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.StepInstances
  alias UserDocs.ProcessInstances.ProcessInstance

  def list_process_instances() do
    base_process_instances_query()
    |> Repo.all()
  end

  defp base_process_instances_query(), do: from(process_instances in ProcessInstance)

  def get_process_instance!(id) do
    base_process_instance_query(id)
    |> Repo.one!()
  end

  defp base_process_instance_query(id) do
    from(process_instance in ProcessInstance, where: process_instance.id == ^id)
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

  def toggle_process_instance_expanded(%ProcessInstance{ expanded: nil } = process_instance) do
    update_process_instance(process_instance, %{ expanded: true })
  end
  def toggle_process_instance_expanded(%ProcessInstance{} = process_instance) do
    update_process_instance(process_instance, %{ expanded: not process_instance.expanded })
  end

  def update_process_instance(%ProcessInstance{} = process_instance, attrs) do
    process_instance
    |> ProcessInstance.changeset(attrs)
    |> Repo.update()
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
    ++ Enum.map(process_instance.step_instances, &StepInstances.format_step_instance_for_export/1)
    ++ [ complete_attrs ]
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

  def delete_process_instance(%ProcessInstance{} = process_instance) do
    Repo.delete(process_instance)
  end

  def change_process_instance(%ProcessInstance{} = process_instance, attrs \\ %{}) do
    ProcessInstance.changeset(process_instance, attrs)
  end
end
