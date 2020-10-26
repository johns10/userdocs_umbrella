defmodule UserDocs.Automation.Step do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.Element
  alias UserDocs.Web.Page
  alias UserDocs.Automation.StepType
  alias UserDocs.Web.Annotation
  alias UserDocs.Automation.Process
  alias UserDocs.Media.Screenshot
  alias UserDocs.Automation.Step.Name

  @derive {Jason.Encoder, only: [:order, :name, :url, :text, :width, :height, :page_reference,
    :screenshot, :page, :process, :element, :annotation, :step_type]}
  schema "steps" do
    field :order, :integer
    field :name, :string
    field :url, :string
    field :text, :string
    field :width, :integer
    field :height, :integer
    field :page_reference, :string

    has_one :screenshot, Screenshot

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
    |> cast_assoc(:page)
    |> validate_required([:order])
  end

  def handle_changes(changes, state) do
    UserDocs.Automation.Step.ChangeHandler.execute(changes, state)
  end

  def safe(annotation, handlers \\ %{})
  def safe(step = %UserDocs.Automation.Step{}, handlers) do
    base_safe(step)
    |> maybe_safe_step_type(handlers[:step_type], step.step_type, handlers)
    |> maybe_safe_annotation(handlers[:annotation], step.annotation, handlers)
    |> maybe_safe_element(handlers[:element], step.element, handlers)
    |> maybe_safe_screenshot(handlers[:screenshot], step.screenshot, handlers)
  end
  def safe(nil, _), do: nil

  def base_safe(step) do
    %{
      id: step.id,
      order: step.order,
      name: step.name,
      url: step.url,
      text: step.text,
      width: step.width,
      height: step.height,
      page_reference: step.page_reference,
    }
  end

  def maybe_safe_step_type(step, nil, _, _), do: step
  def maybe_safe_step_type(step, handler, step_type, handlers) do
    Map.put(step, :step_type, handler.(step_type, handlers))
  end

  def maybe_safe_annotation(step, nil, _, _), do: step
  def maybe_safe_annotation(step, handler, annotation, handlers) do
    Map.put(step, :annotation, handler.(annotation, handlers))
  end

  def maybe_safe_element(step, nil, _, _), do: step
  def maybe_safe_element(step, handler, element, handlers) do
    Map.put(step, :element, handler.(element, handlers))
  end

  def maybe_safe_screenshot(step, nil, _, _), do: step
  def maybe_safe_screenshot(step, handler, screenshot, handlers) do
    Map.put(step, :screenshot, handler.(screenshot, handlers))
  end

  def name(step = %UserDocs.Automation.Step{}) do
    Name.execute(step)
  end
end
