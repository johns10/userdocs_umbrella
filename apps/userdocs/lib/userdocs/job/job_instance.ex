defmodule UserDocs.Jobs.JobInstance do
  #@derive {Inspect, only: [:id, :name, :order, :status, :process_instances, :step_instances ]}

  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.Jobs.Job

  @derive {Jason.Encoder, only: [:id, :uuid, :order, :status, :name, :type]}
  schema "job_instances" do
    field :uuid, :binary_id
    field :order, :integer
    field :status, :string
    field :name, :string
    field :type, :string
    field :errors, {:array, :map}
    field :warnings, {:array, :map}
    field :expanded, :boolean

    belongs_to :job, Job
    has_many :step_instances, StepInstance, on_replace: :nilify
    has_many :process_instances, ProcessInstance, on_replace: :nilify
  end

  def changeset(process_instance, attrs) do
    process_instance
    |> cast(attrs, [:uuid, :order, :status, :name, :type, :errors, :warnings, :job_id])
    |> cast_assoc(:step_instances)
    |> cast_assoc(:process_instances)
    |> validate_required([:status])
  end
end
