defmodule UserDocs.Automation.Process do
  use Ecto.Schema
  import Ecto.Changeset
  alias UserDocs.Automation.Step

  schema "processes" do
    field :name, :string

    has_many :step, Step

    timestamps()
  end

  @doc false
  def changeset(process, attrs) do
    process
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
