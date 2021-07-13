defmodule UserDocs.Automation.StepForm do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  alias UserDocs.Web.Element
  alias UserDocs.Web.Page
  alias UserDocs.Web.AnnotationForm
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
    embeds_one :annotation, AnnotationForm, on_replace: :update

    field :screenshot_form_enabled, :boolean
    embeds_one :screenshot, Screenshot, on_replace: :update do
      field :name, :string
      field :base64, :string

      field :aws_screenshot, :string
      field :aws_provisional_screenshot, :string
      field :aws_diff_screenshot, :string

      field :step_id, :integer
    end
  end

  @doc false
  def changeset(step_form, attrs) do
    step_form
    |> cast(attrs, [ :order, :name, :text, :width, :height ])
    |> cast(attrs, [ :process_id, :page_id, :element_id, :annotation_id, :step_type_id ])
    |> cast_embed(:element, with: &Element.fields_changeset/2)
    |> cast_embed(:annotation, with: &AnnotationForm.changeset/2)
    |> cast_embed(:page, with: &Page.fields_changeset/2)
    |> cast_embed(:screenshot, with: &Screenshot.fields_changeset/2)
    |> validate_required([:order])
  end

  def enabler_fields do
    [
      :url_enabled,
      :text_enabled,
      :width_enabled,
      :height_enabled,
      :page_id_enabled,
      :page_form_enabled,
      :element_id_enabled,
      :element_form_enabled,
      :annotation_id_enabled,
      :annotation_form_enabled,
      :screenshot_form_enabled
    ]
  end
end
