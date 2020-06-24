defmodule UserDocs.Automation.Step do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Process

  schema "steps" do
    field :order, :integer
    field :name, :string
    field :element_id, :id
    field :annotation_id, :id
    field :step_type_id, :id

    belongs_to :process, Process

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:order, :name, :process_id])
    |> foreign_key_constraint(:process_id)
    |> validate_required([:order])
  end
end
