defmodule UserDocs.Web.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.AnnotationType
  alias UserDocs.Web.Element
  alias UserDocs.Web.Page
  alias UserDocs.Documents.Content

  schema "annotations" do
    field :description, :string
    field :label, :string
    field :name, :string

    belongs_to :page, Page

    belongs_to :annotation_type, AnnotationType
    belongs_to :element, Element
    belongs_to :content, Content

    timestamps()
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [:name, :label, :description, :page_id,
      :annotation_type_id, :element_id, :content_id])
    |> foreign_key_constraint(:page_id)
    |> foreign_key_constraint(:annotation_type_id)
    |> foreign_key_constraint(:elment_id)
    |> foreign_key_constraint(:content_id)
    |> validate_required([:name, :label, :description])
  end
end
