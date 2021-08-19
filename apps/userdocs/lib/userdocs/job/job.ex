defmodule UserDocs.Jobs.Job do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Jobs.JobStep
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Jobs.JobInstance
  alias UserDocs.Users.Team


  schema "jobs" do
    field :order, :integer
    field :status, :string
    field :name, :string
    field :errors, {:array, :map}
    field :warnings, {:array, :map}

    has_one :last_job_instance, JobInstance

    has_many :job_steps, JobStep, on_delete: :delete_all
    has_many :job_processes, JobProcess, on_delete: :delete_all

    belongs_to :team, Team

    timestamps()
  end


  def changeset(job, attrs) do
    job
    |> cast(attrs, [ :team_id, :order, :status, :name, :errors, :warnings  ])
    |> cast_assoc(:last_job_instance)
    |> cast_assoc(:job_steps)
    |> cast_assoc(:job_processes)
    #|> put_assoc(:step_instances, Map.get(attrs, :step_instances, job.step_instances))
    #|> put_assoc(:process_instances, Map.get(attrs, :process_instances, job.process_instances))s
  end
end
