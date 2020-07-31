defmodule UserDocs.Web.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.AnnotationType
  alias UserDocs.Web.Page
  alias UserDocs.Documents.Content

  schema "annotations" do
    field :name, :string
    field :description, :string
    field :label, :string
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

  def safe(annotation = %UserDocs.Web.Annotation{}, handlers) do
    annotation_type_handler = Map.get(handlers, :annotation_type)

    %{
      label: annotation.label,
      x_orientation: annotation.x_orientation,
      y_orientation: annotation.y_orientation,
      size: annotation.size,
      color: annotation.color,
      thickness: annotation.thickness,
      x_offset: annotation.x_offset,
      y_offset: annotation.y_offset,
      font_size: annotation.font_size,

      annotation_type: annotation_type_handler.(annotation.annotation_type, handlers)
    }
  end
  def safe(nil, _), do: nil
end
