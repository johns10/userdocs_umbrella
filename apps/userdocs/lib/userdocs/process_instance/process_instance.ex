defmodule UserDocs.ProcessInstances.ProcessInstance do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Process
  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.Jobs.Job

  schema "process_instances" do
    field :order, :integer
    field :status, :string
    field :name, :string
    field :type, :string
    field :attrs, :map
    field :errors, { :array, :map }
    field :warnings, { :array, :map }
    field :expanded, :boolean

    belongs_to :job, Job, on_replace: :nilify
    belongs_to :process, Process
    has_many :step_instances, StepInstance, on_replace: :nilify
  end


  def changeset(process_instance, attrs) do
    process_instance
    |> cast(attrs, [ :order, :status, :name, :type, :errors, :warnings, :process_id, :expanded  ])
    #|> put_assoc(:process, Map.get(attrs, :process, process_instance.process))
    |> cast_assoc(:step_instances)
    |> validate_required([ :order, :status, :name, :process_id ])
  end
end
