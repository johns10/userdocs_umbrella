defmodule UserDocs.Automation.StepType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "step_types" do
    field :args, {:array, :string}
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(step_type, attrs) do
    step_type
    |> cast(attrs, [:name, :args])
    |> validate_required([:name, :args])
  end
end
