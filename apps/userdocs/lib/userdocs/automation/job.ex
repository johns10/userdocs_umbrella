defmodule UserDocs.Automation.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :job_type, :string
    field :page_id, :id
    field :version_id, :id

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:job_type])
    |> validate_required([:job_type])
  end
end
