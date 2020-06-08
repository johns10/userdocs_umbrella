defmodule UserDocs.Documents.Content do
  use Ecto.Schema
  import Ecto.Changeset

  schema "content" do
    field :description, :string
    field :name, :string
    field :team_id, :id

    timestamps()
  end

  @doc false
  def changeset(content, attrs) do
    content
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
