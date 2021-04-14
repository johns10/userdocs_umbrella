defmodule UserDocs.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset


  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.Users.Team

  schema "jobs" do
    field :order, :integer
    field :status, :string
    field :name, :string
    field :errors, { :array, :map }
    field :warnings, { :array, :map }

    has_many :process_instances, ProcessInstance, on_replace: :nilify
    has_many :step_instances, StepInstance, on_replace: :nilify

    belongs_to :team, Team

    timestamps()
  end


  def changeset(job, attrs) do
    job
    |> cast(attrs, [ :team_id, :order, :status, :name, :errors, :warnings  ])
    |> cast_assoc(:process_instances)
    |> cast_assoc(:step_instances)
    #|> put_assoc(:step_instances, Map.get(attrs, :step_instances, job.step_instances))
    #|> put_assoc(:process_instances, Map.get(attrs, :process_instances, job.process_instances))s
  end
end
