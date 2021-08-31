defmodule UserDocs.Automation.Step do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  alias UserDocs.Web.Element
  alias UserDocs.Web.Page
  alias UserDocs.Automation.StepType
  alias UserDocs.Web.Annotation
  alias UserDocs.Automation.Process
  alias UserDocs.Media.Screenshot
  alias UserDocs.Automation.Step.Name
  alias UserDocs.StepInstances.StepInstance

  alias UserDocs.Automation.Step.Changeset

  @derive {Jason.Encoder, only: [:id, :order, :name, :url, :text, :width, :height, :page_reference]}

  schema "steps" do
    field :order, :integer
    field :name, :string
    field :url, :string
    field :text, :string
    field :width, :integer
    field :height, :integer
    field :page_reference, :string

    belongs_to :page, Page, on_replace: :update
    belongs_to :process, Process
    belongs_to :element, Element, on_replace: :update
    belongs_to :annotation, Annotation, on_replace: :update
    belongs_to :step_type, StepType

    has_one :screenshot, Screenshot
    has_one :last_step_instance, StepInstance, on_replace: :nilify

    has_many :step_instances, StepInstance

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    fields_changeset(step, attrs)
    |> assoc_changeset()
    |> names_changeset()
    |> cast_assoc(:last_step_instance)
    |> validate_required([:order])
  end

  def runner_changeset(step, attrs) do
    step
    |> cast(attrs, [])
    |> cast_assoc(:screenshot)
    |> cast_assoc(:last_step_instance, with: &UserDocs.StepInstances.StepInstance.changeset/2)
  end

  def create_nested_changeset(step, attrs) do
    IO.puts("create_nested_changeset")
    step
    |> cast(attrs, [:page_id, :annotation_id, :element_id, :process_id, :step_type_id])
  end

  def fields_changeset(step, attrs) do
    step
    |> cast(attrs, [:order, :name, :url, :text, :width, :height, :page_reference])
    |> cast(attrs, [:process_id, :page_id, :element_id, :annotation_id, :step_type_id])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:page)
    |> foreign_key_constraint(:element)
    |> foreign_key_constraint(:annotation)
    |> foreign_key_constraint(:step_type)
  end

  def assoc_changeset(changeset) do
    changeset
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> cast_assoc(:page)
    |> cast_assoc(:screenshot)
  end

  def names_changeset(changeset) do
    changeset
    |> put_annotation_name()
    |> put_name()
  end

  def safe(step, handlers) do
    UserDocs.Automation.Step.Safe.apply(step, handlers)
  end

  def put_annotation_name(%{data: %{annotation: %Ecto.Association.NotLoaded{}}} = changeset), do: changeset
  def put_annotation_name(%{data: %{element: %Ecto.Association.NotLoaded{}}} = changeset), do: changeset
  def put_annotation_name(changeset) do
    case get_field(changeset, :annotation, nil) do
      nil -> changeset
      "" -> changeset
      annotation ->
        case get_field(changeset, :element, nil) do
          nil -> changeset
          "" -> changeset
          element ->
            name = UserDocs.Web.Annotation.Name.execute(annotation, element)
            Ecto.Changeset.update_change(changeset, :annotation,
              fn(a) -> Ecto.Changeset.put_change(a, :name, name) end)
        end
    end
  end

  def put_name(%{data: %{step_type: %Ecto.Association.NotLoaded{}}} = changeset) do
    changeset
  end
  def put_name(changeset) do
    name = Name.execute(changeset)
    # Logger.debug("Changing Step Name to #{name}")
    Ecto.Changeset.put_change(changeset, :name, name)
  end

  def name(step = %UserDocs.Automation.Step{}) do
    Name.execute(step)
  end
end
