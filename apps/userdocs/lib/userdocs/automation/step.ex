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
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> cast_assoc(:page)
    |> put_annotation_name()
    |> put_name()
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

  def change_to_new_foreign_key(step, attrs) do
    step
    |> foreign_key_constraint(:page)
    |> foreign_key_constraint(:element)
    |> foreign_key_constraint(:annotation)
    |> handle_params()
  end

  def change_remaining(step, attrs) do
    step
    |> cast(attrs, [ :process_id, :step_type_id ])
    |> cast(attrs, [ :name, :order, :url, :text, :width, :height, :page_reference ])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:step_type)
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> cast_assoc(:page)
    # |> validate_assoc_action()
    |> put_annotation_name()
    |> put_name()
  end

  def inspect_changeset(changeset) do
    changeset
  end

  def validate_action(changeset) do
    UserDocs.Automation.Step.Action.validate(changeset)
  end

  def validate_assoc_action(changeset) do
    UserDocs.Automation.Step.Action.validate_assoc(changeset)
  end

  # This function removes nested params if the underlying id changed, because
  # we'll replace them with new ones in the data later
  def handle_params(changeset) do
    # Logger.debug("Original Params: #{inspect(changeset.params)}")
    updated_params =
      case changeset.changes do
        %{ element_id: element_id } ->
          Logger.debug("Removing element params")
          Map.delete(changeset.params, "element")
        %{ annotation_id: annotation_id } ->
          Logger.debug("Removing annotation params")
          Map.delete(changeset.params, "annotation")
        %{ page_id: page_id } ->
          Logger.debug("Removing page params")
          Map.delete(changeset.params, "page")
        _ ->
          Logger.debug("not removing params")
          changeset.params
      end

    Map.put(changeset, :params, updated_params)
  end

  def safe(step, handlers) do
    UserDocs.Automation.Step.Safe.apply(step, handlers)
  end

  def put_annotation_name(%{ data: %{ annotation: %Ecto.Association.NotLoaded{} }} = changeset) do
    changeset
  end
  def put_annotation_name(%{ data: %{ element: %Ecto.Association.NotLoaded{} }} = changeset) do
    changeset
  end
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

  def put_name(%{ data: %{ step_type: %Ecto.Association.NotLoaded{} }} = changeset) do
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
