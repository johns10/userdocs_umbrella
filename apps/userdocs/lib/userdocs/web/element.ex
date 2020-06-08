defmodule UserDocs.Web.Element do
  use Ecto.Schema
  import Ecto.Changeset

  schema "elements" do
    field :name, :string
    field :selector, :string
    field :strategy, :string
    field :page_id, :id

    timestamps()
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:name, :strategy, :selector])
    |> validate_required([:name, :strategy, :selector])
  end
end
