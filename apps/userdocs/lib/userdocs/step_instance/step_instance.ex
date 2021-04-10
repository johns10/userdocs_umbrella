defmodule UserDocs.StepInstances.StepInstance do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Step
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.Jobs.Job

  schema "step_instances" do
    field :order, :integer
    field :status, :string
    field :name, :string
    field :type, :string
    field :attrs, :map
    field :errors, { :array, :map }
    field :warnings, { :array, :map }

    belongs_to :job, Job, on_replace: :nilify
    belongs_to :process_instance, ProcessInstance, on_replace: :nilify
    belongs_to :step, Step, on_replace: :nilify
  end

  def changeset(step_instance, attrs) do
    step_instance
    |> cast(attrs, [ :order, :status, :name, :type, :attrs, :errors, :warnings, :step_id  ])
    |> validate_required([ :order, :status, :step_id ])
  end
end
