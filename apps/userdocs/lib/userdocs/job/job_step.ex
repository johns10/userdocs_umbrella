defmodule UserDocs.Jobs.JobStep do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Step
  alias UserDocs.Jobs.Job
  alias UserDocs.StepInstances.StepInstance

  schema "job_steps" do
    field :order, :integer

    belongs_to :job, Job
    belongs_to :step, Step
    belongs_to :step_instance, StepInstance

    timestamps()
  end

  def changeset(step_instance, attrs) do
    step_instance
    |> cast(attrs, [:order, :job_id, :step_id, :step_instance_id])
    |> foreign_key_constraint(:step_id)
    |> foreign_key_constraint(:job_id)
    |> validate_required([:order])
  end
end
