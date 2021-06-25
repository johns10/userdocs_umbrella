defmodule UserDocs.Automation.StepForm do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  alias UserDocs.Web.Element
  alias UserDocs.Web.Page
  alias UserDocs.Web.Annotation
  alias UserDocs.Media.Screenshot

  schema "step_form" do
    field :order, :integer
    field :name, :string

    field :url_enabled, :boolean
    field :url, :string

    field :text_enabled, :boolean
    field :text, :string

    field :width_enabled, :boolean
    field :width, :integer

    field :height_enabled, :boolean
    field :height, :integer

    field :process_id, :integer
    field :step_type_id, :integer

    field :page_id_enabled, :boolean
    field :page_id, :integer

    field :page_form_enabled, :boolean
    embeds_one :page, Page, on_replace: :update do
      field :order, :integer
      field :name, :string
      field :url, :string

      field :version_id, :integer
    end

    field :element_id_enabled, :boolean
    field :element_id, :integer

    field :element_form_enabled, :boolean
    embeds_one :element, Element, on_replace: :update do
      field :name, :string
      field :selector, :string

      field :strategy_id, :integer
      field :page_id, :integer
    end

    field :annotation_id_enabled, :boolean
    field :annotation_id, :integer

    field :annotation_form_enabled, :boolean
    embeds_one :annotation, Annotation, on_replace: :update do
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
      field :page_id, :integer
    end

    embeds_one :screenshot, Screenshot do
      field :name, :string
    end
  end

  @doc false
  def changeset(step_form, attrs) do
    step_form
    |> cast(attrs, [ :order, :name, :text, :width, :height ])
    |> cast(attrs, [ :process_id, :page_id, :element_id, :annotation_id, :step_type_id ])
    |> cast_embed(:element, with: &Element.fields_changeset/2)
    |> cast_embed(:annotation, with: &Annotation.changeset/2)
    |> cast_embed(:page, with: &Page.fields_changeset/2)
    |> cast_embed(:screenshot)
    |> validate_required([:order])
  end
end
