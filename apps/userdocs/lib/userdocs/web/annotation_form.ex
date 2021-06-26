defmodule UserDocs.Web.AnnotationForm do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Documents.Content

  schema "annotation_form" do
    field :name_enabled, :string
    field :name, :string
    field :label_enabled, :string
    field :label, :string
    field :x_orientation_enabled, :string
    field :x_orientation, :string
    field :y_orientation_enabled, :string
    field :y_orientation, :string
    field :size_enabled, :integer
    field :size, :integer
    field :color_enabled, :string
    field :color, :string
    field :thickness_enabled, :integer
    field :thickness, :integer
    field :x_offset_enabled, :integer
    field :x_offset, :integer
    field :y_offset_enabled, :integer
    field :y_offset, :integer
    field :font_size_enabled, :integer
    field :font_size, :integer
    field :font_color_enabled, :string
    field :font_color, :string

    field :annotation_type_id, :integer
    field :page_id, :integer

    field :content_id, :integer
    field :content_version_id, :integer

    embeds_one :content, Content, on_replace: :update
  end

  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [
        :name, :label, :x_orientation, :y_orientation,
        :size, :color, :thickness, :x_offset, :y_offset,
        :font_size, :page_id, :annotation_type_id,
        :content_id, :content_version_id ])
    |> validate_required([:page_id])
  end

  def enabler_fields do
    [
      :name_enabled,
      :label_enabled,
      :x_orientation_enabled,
      :y_orientation_enabled,
      :size_enabled,
      :color_enabled,
      :thickness_enabled,
      :x_offset_enabled,
      :y_offset_enabled,
      :font_size_enabled,
      :font_color_enabled
    ]
  end
end
