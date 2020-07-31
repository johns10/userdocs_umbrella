defmodule UserDocs.Automation.Step do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.Element
  alias UserDocs.Web.Page
  alias UserDocs.Automation.StepType
  alias UserDocs.Web.Annotation
  alias UserDocs.Automation.Process

  schema "steps" do
    field :order, :integer
    field :name, :string
    field :url, :string
    field :text, :string
    field :width, :integer
    field :height, :integer
    field :page_reference, :string

    belongs_to :page, Page
    belongs_to :process, Process
    belongs_to :element, Element
    belongs_to :annotation, Annotation
    belongs_to :step_type, StepType

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:order, :name, :url, :text, :width, :height, :page_reference,
      :process_id, :page_id, :element_id, :annotation_id, :step_type_id])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:page)
    |> foreign_key_constraint(:element)
    |> foreign_key_constraint(:annotation)
    |> foreign_key_constraint(:step_type)
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> validate_required([:order])
  end

  def safe(step, handlers) do
    annotation_handler = Map.get(handlers, :annotation)
    element_handler = Map.get(handlers, :element)
    step_type_handler = Map.get(handlers, :step_type)

    %{
      id: step.id,
      order: step.order,
      name: step.name,
      url: step.url,
      text: step.text,
      width: step.width,
      height: step.height,
      page_reference: step.page_reference,

      annotation: annotation_handler.(step.annotation, handlers),
      element: element_handler.(step.element, handlers),
      step_type: step_type_handler.(step.step_type, handlers)
    }
  end
end
