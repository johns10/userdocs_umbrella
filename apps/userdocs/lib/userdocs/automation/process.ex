defmodule UserDocs.Automation.Process do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Step
  alias UserDocs.Projects.Project
  alias UserDocs.ProcessInstances.ProcessInstance

  @derive {Jason.Encoder, only: [:id, :order, :name]}
  schema "processes" do
    field :order, :integer
    field :name, :string

    belongs_to :project, Project

    has_many :steps, Step

    has_one :last_process_instance, ProcessInstance, on_replace: :nilify

    has_many :process_instances, ProcessInstance

    timestamps()
  end

  @doc false
  def changeset(process, attrs) do
    process
    |> cast(attrs, [:name, :project_id])
    |> foreign_key_constraint(:project_id)
    |> cast_assoc(:last_process_instance)
    |> cast_assoc(:steps)
    |> validate_required([:name])
  end

  def runner_changeset(step, attrs) do
    step
    |> cast(attrs, [])
    |> cast_assoc(:last_process_instance)
  end
end
