defmodule UserDocs.Jobs.JobProcess do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Process
  alias UserDocs.Jobs.Job
  alias UserDocs.ProcessInstances.ProcessInstance

  schema "job_processes" do
    field :order, :integer

    belongs_to :job, Job
    belongs_to :process, Process
    belongs_to :process_instance, ProcessInstance

    field :collapsed, :boolean, default: true

    timestamps()
  end

  def changeset(step_instance, attrs) do
    step_instance
    |> cast(attrs, [ :order, :job_id, :process_id, :process_instance_id, :collapsed  ])
    |> foreign_key_constraint(:process_id)
    |> foreign_key_constraint(:job_id)
    |> foreign_key_constraint(:process_instance_id)
    |> validate_required([ :order ])
  end
end
