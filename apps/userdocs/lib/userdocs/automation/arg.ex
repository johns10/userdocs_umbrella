defmodule UserDocs.Automation.Arg do
  use Ecto.Schema
  import Ecto.Changeset

  schema "args" do
    field :key, :string
    field :value, :string
    field :step_id, :id

    timestamps()
  end

  @doc false
  def changeset(arg, attrs) do
    arg
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
end
