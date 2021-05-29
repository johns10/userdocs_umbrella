defmodule UserDocs.Automation.Process do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Step
  alias UserDocs.Projects.Version
  alias UserDocs.ProcessInstances.ProcessInstance

  schema "processes" do
    field :order, :integer
    field :name, :string

    belongs_to :version, Version

    has_many :steps, Step

    has_one :last_process_instance, ProcessInstance, on_replace: :nilify

    has_many :process_instances, ProcessInstance

    timestamps()
  end

  @doc false
  def changeset(process, attrs) do
    process
    |> cast(attrs, [:order, :name, :version_id])
    |> foreign_key_constraint(:version_id)
    |> cast_assoc(:last_process_instance)
    |> cast_assoc(:steps)
    |> validate_required([:name])
  end

  def runner_changeset(step, attrs) do
    step
    |> cast(attrs, [])
    |> cast_assoc(:last_process_instance)
  end

  def safe(process, handlers) do
    UserDocs.Automation.Process.Safe.apply(process, handlers)
  end
end
