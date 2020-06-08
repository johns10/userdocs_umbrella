defmodule UserDocs.Automation.Step do
  use Ecto.Schema
  import Ecto.Changeset

  schema "steps" do
    field :order, :integer
    field :element_id, :id
    field :annotation_id, :id
    field :step_type_id, :id

    belongs_to :process, Process

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:order, :process_id])
    |> foreign_key_constraint(:process_id)
    |> validate_required([:order])
  end
end
