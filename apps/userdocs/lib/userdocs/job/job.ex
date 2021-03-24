defmodule UserDocs.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset


  alias UserDocs.Jobs.StepInstance
  alias UserDocs.Jobs.ProcessInstance

  embedded_schema do
    field :order, :integer
    field :status, :string
    field :name, :string
    field :errors, { :array, :map }
    field :warnings, { :array, :map }

    has_many :process_instances, ProcessInstance, on_replace: :nilify
    has_many :step_instances, StepInstance, on_replace: :nilify
  end


  def changeset(job, attrs) do
    job
    |> cast(attrs, [ :order, :status, :name, :errors, :warnings  ])
    |> put_assoc(:process_instances, Map.get(attrs, :process_instances, job.process_instances))
    |> put_assoc(:step_instances, Map.get(attrs, :step_instances, job.step_instances))
  end
end
