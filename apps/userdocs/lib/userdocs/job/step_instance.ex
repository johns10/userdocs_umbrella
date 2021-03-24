defmodule UserDocs.Jobs.StepInstance do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Step
  alias UserDocs.Jobs.ProcessInstance
  alias UserDocs.Jobs.Job

  embedded_schema do
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
    |> put_assoc(:step, Map.get(attrs, :step, nil))
    |> validate_required([ :order, :name, :status, :attrs, :step_id ])
  end

  def create_changeset(_, attrs) do
    %UserDocs.Jobs.StepInstance{ step: nil }
    |> cast(attrs, [ :order, :status, :name, :type, :attrs, :errors, :warnings, :step_id  ])
    |> put_assoc(:step, Map.get(attrs, :step, nil))
    |> validate_required([ :order, :name, :status, :attrs, :step_id ])
  end
end
