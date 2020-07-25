defmodule UserDocs.Web.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.AnnotationType
  alias UserDocs.Web.Page
  alias UserDocs.Documents.Content

  schema "annotations" do
    field :description, :string
    field :label, :string
    field :name, :string
    field :x_orientation, :string
    field :y_orientation, :string
    field :size, :integer
    field :color, :string
    field :thickness, :integer
    field :x_offset, :integer
    field :y_offset, :integer
    field :font_size, :integer
    field :font_color, :string

    belongs_to :page, Page

    belongs_to :annotation_type, AnnotationType
    belongs_to :content, Content

    timestamps()
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [:name, :label, :description,
    :x_orientation, :y_orientation, :size, :color, :thickness, :x_offset, :y_offset, :font_size,
    :page_id, :annotation_type_id, :content_id])
    |> validate_required([:name, :description])
  end
end
