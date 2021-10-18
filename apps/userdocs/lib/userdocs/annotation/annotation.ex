defmodule UserDocs.Annotations.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  alias UserDocs.Annotations.AnnotationType
  alias UserDocs.Web.Page
  alias UserDocs.Annotations.Annotation
  alias UserDocs.Annotations.Annotation.Name
  alias UserDocs.Elements.Element

  @derive {Jason.Encoder, only: [:id, :name, :label, :x_orientation, :y_orientation,
    :size, :color, :thickness, :x_offset, :y_offset, :font_size, :font_color]}

  schema "annotations" do
    field :name, :string
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

    timestamps()
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [
        :name, :label, :x_orientation, :y_orientation,
        :size, :color, :thickness, :x_offset, :y_offset,
        :font_size, :page_id, :annotation_type_id])
    |> foreign_key_constraint(:page_id)
    |> foreign_key_constraint(:annotation_type_id)
    |> validate_required([:page_id])
    |> ignore_missing()
  end

  def ignore_missing(changeset) do
    case changeset do
      %{valid?: false, changes: changes} = changeset when changes == %{} ->
        %{changeset | action: :ignore}
      changeset ->
        changeset
    end
  end


  def safe(annotation, handlers \\ %{})
  def safe(annotation = %Annotation{}, handlers) do
    base_safe(annotation)
    |> maybe_safe_annotation_type(handlers[:annotation_type], annotation.annotation_type, handlers)
  end
  def safe(nil, _), do: nil

  def base_safe(annotation = %Annotation{}) do
    %{
      id: annotation.id,
      label: annotation.label,
      x_orientation: annotation.x_orientation,
      y_orientation: annotation.y_orientation,
      size: annotation.size,
      color: annotation.color,
      thickness: annotation.thickness,
      x_offset: annotation.x_offset,
      y_offset: annotation.y_offset,
      font_size: annotation.font_size
    }
  end

  def maybe_safe_annotation_type(annotation, nil, _, _), do: annotation
  def maybe_safe_annotation_type(annotation, handler, annotation_type, handlers) do
    Map.put(annotation, :annotation_type, handler.(annotation_type, handlers))
  end

  def put_name(changeset) do
    case Ecto.Changeset.apply_action(changeset, :update) do
      { :ok, annotation } ->
        name = name(annotation)
        Ecto.Changeset.put_change(changeset, :name, name)
      { :error, changeset } -> changeset
    end
  end

  def name(annotation = %Annotation{}) do
    Name.execute(annotation, Map.get(annotation, :element, %Element{}))
  end
end
