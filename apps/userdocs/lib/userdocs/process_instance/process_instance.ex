defmodule UserDocs.ProcessInstances.ProcessInstance do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Process
  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.Jobs.JobInstance
  alias UserDocs.Jobs.JobProcess

  @derive {Jason.Encoder, only: [:id, :uuid, :order, :status, :name, :type]}
  schema "process_instances" do
    field :uuid, :binary_id
    field :order, :integer
    field :status, :string
    field :name, :string
    field :type, :string
    field :attrs, :map
    field :errors, {:array, :map}
    field :warnings, {:array, :map}
    field :expanded, :boolean

    belongs_to :job_instance, JobInstance, on_replace: :nilify
    belongs_to :process, Process

    has_one :job_process, JobProcess

    has_many :step_instances, StepInstance, on_replace: :nilify
  end

  def changeset(process_instance, attrs) do
    process_instance
    |> cast(attrs, [:uuid, :order, :status, :name, :type, :errors, :warnings, :process_id, :expanded, :job_instance_id])
    |> cast_assoc(:step_instances)
    |> validate_required([:status, :name, :process_id])
  end

  def fields_changeset(process_instance, attrs) do
    process_instance
    |> cast(attrs, [:uuid, :order, :status, :name, :type, :errors, :warnings, :process_id, :expanded, :job_instance_id])
    |> validate_required([:status, :name, :process_id])
  end
end
