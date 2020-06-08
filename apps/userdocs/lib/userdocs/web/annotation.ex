defmodule UserDocs.Web.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "annotations" do
    field :description, :string
    field :label, :string
    field :name, :string
    field :annotation_type_id, :id
    field :page_id, :id
    field :element_id, :id
    field :content_id, :id

    timestamps()
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [:name, :label, :description])
    |> validate_required([:name, :label, :description])
  end
end
