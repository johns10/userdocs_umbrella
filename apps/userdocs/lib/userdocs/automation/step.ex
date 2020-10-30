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
    |> cast(attrs, [ :order, :name, :url, :text, :width, :height, :page_reference ])
    |> cast(attrs, [ :process_id, :page_id, :element_id, :annotation_id, :step_type_id ])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:page)
    |> foreign_key_constraint(:element)
    |> foreign_key_constraint(:annotation)
    |> foreign_key_constraint(:step_type)
    |> validate_assoc_action()
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> cast_assoc(:page)
    |> put_annotation_name()
    |> put_name()
    |> cast(attrs, [ :name ])
    |> validate_required([:order])
  end

  def change_nested_foreign_keys(step, attrs) do
    step
    |> cast(attrs, [ :page_id, :element_id, :annotation_id ])
    |> foreign_key_constraint(:page)
    |> foreign_key_constraint(:element)
    |> foreign_key_constraint(:annotation)
    |> handle_params()
  end

  def change_remaining(step, attrs) do
    step
    |> cast(attrs, [ :process_id, :step_type_id ])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:step_type)
    |> cast(attrs, [:order, :url, :text, :width, :height, :page_reference ])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:step_type)
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> cast_assoc(:page)
    |> validate_assoc_action()
    |> put_annotation_name()
    |> put_name()
    |> cast(attrs, [ :name ])
  end

  def inspect_changeset(changeset) do
    IO.inspect(changeset.data)
    changeset
  end

  # This function removes nested params if the underlying id changed, because
  # we'll replace them with new ones in the data later
  def handle_params(changeset) do
    # Logger.debug("Original Params: #{inspect(changeset.params)}")

    updated_params =
      changeset.params
      |> maybe_remove_nested_params(changeset.changes, :element_id, "element")
      |> maybe_remove_nested_params(changeset.changes, :annotation_id, "annotation")

    # Logger.debug("Updated Params: #{inspect(updated_params)}")

    Map.put(changeset, :params, updated_params)
  end

  def maybe_remove_nested_params(params, changes, key, key_to_delete) do
    Logger.debug("Removing nested params for #{key_to_delete}")
    if Map.has_key?(changes, key) do
      Map.delete(params, key_to_delete)
    else
      params
    end
  end

  def validate_assoc_action(changeset) do
    UserDocs.Automation.Step.Action.validate_assoc(changeset)
  end

  def safe(step, handlers) do
    UserDocs.Automation.Step.Safe.apply(step, handlers)
  end

  def put_annotation_name(changeset) do
    step = apply_changes(changeset)
    annotation = step.annotation
    element = step.element

    name =
      UserDocs.Web.Annotation.Name.execute(annotation, element)

    Logger.debug("Putting annotation name #{name}")

    Ecto.Changeset.update_change(changeset, :annotation,
      fn(a) -> Ecto.Changeset.put_change(a, :name, name) end)

  end

  def put_name(changeset) do
    step = apply_changes(changeset)
    name = Name.execute(step)
    Ecto.Changeset.put_change(changeset, :name, name)
  end

  def name(step = %UserDocs.Automation.Step{}) do
    Name.execute(step)
  end
end
