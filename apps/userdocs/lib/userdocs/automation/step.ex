defmodule UserDocs.Automation.Step do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.Element
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

    belongs_to :process, Process
    belongs_to :element, Element
    belongs_to :annotation, Annotation
    belongs_to :step_type, StepType

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:order, :name, :process_id, :element_id, :annotation_id, :step_type_id, :url, :text, :width, :height])
    |> foreign_key_constraint(:process_id)
    |> foreign_key_constraint(:element)
    |> foreign_key_constraint(:annotation)
    |> foreign_key_constraint(:step_type)
    |> validate_required([:order])
  end
end
