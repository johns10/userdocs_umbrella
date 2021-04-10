defmodule UserDocs.ProcessInstances do
  require Logger

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.StepInstances
  alias UserDocs.StepInstances.StepInstance
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

  def create_process_instance(attrs \\ %{}) do
    %ProcessInstance{ expanded: false }
    |> ProcessInstance.changeset(attrs)
    |> Repo.insert()
  end

  def toggle_process_instance_expanded(%ProcessInstance{} = process_instance) do
    attrs = %{ expanded: not process_instance.expanded }
    update_process_instance(process_instance, attrs)
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

  def create_process_instance_from_process(process, order) do
    { step_instance_attrs, _max_order } =
      process.steps
      |> Enum.sort(fn(x, y) -> x.order < y.order end)
      |> Enum.reduce({ [], 1 },
        fn(step, { acc, inner_order }) ->
          { [ StepInstances.base_step_instance_attrs(step, inner_order) | acc ], inner_order + 1 }
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
  def delete_process_instance(%ProcessInstance{} = process_instance) do
    Repo.delete(process_instance)
  end

  def change_process_instance(%ProcessInstance{} = process_instance, attrs \\ %{}) do
    ProcessInstance.changeset(process_instance, attrs)
  end
end
