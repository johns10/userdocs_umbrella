defmodule UserDocs.Automation.Process do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Step
  alias UserDocs.Projects.Version

  schema "processes" do
    field :order, :integer
    field :name, :string

    belongs_to :version, Version

    has_many :steps, Step

    timestamps()
  end

  @doc false
  def changeset(process, attrs) do
    process
    |> cast(attrs, [:order, :name, :version_id])
    |> foreign_key_constraint(:version_id)
    |> validate_required([:name])
  end

  def safe(process = %UserDocs.Automation.Process{}, handlers) do
    step_handler = Map.get(handlers, :step)

    %{
      id: process.id,
      order: process.order,
      name: process.name,

      steps: Enum.map(process.steps, &step_handler.(&1, handlers))
    }
  end
end
