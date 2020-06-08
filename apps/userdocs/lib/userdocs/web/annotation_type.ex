defmodule UserDocs.Web.AnnotationType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "annotation_types" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(annotation_type, attrs) do
    annotation_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
