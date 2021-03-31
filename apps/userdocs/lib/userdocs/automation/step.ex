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

  alias UserDocs.Automation.Step.Changeset

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
    belongs_to :page, Page, on_replace: :update
    belongs_to :process, Process
    belongs_to :element, Element, on_replace: :update
    belongs_to :annotation, Annotation, on_replace: :update
    belongs_to :step_type, StepType

    timestamps()
  end

  @doc false
  def changeset(step, attrs) do
    fields_changeset(step, attrs)
    |> assoc_changeset()
    |> names_changeset()
    |> validate_required([:order])
  end

  def nested_changeset(step, last_step, attrs, state, action) do
    last_change = changeset(last_step, attrs)
    step
  # |> change page
    |> cast(attrs, [ :page_id ])
    |> foreign_key_constraint(:page)
    |> Changeset.handle_page_id_change(state)
    |> Changeset.maybe_replace_page_params(last_change, state)
  # |> change annotation
    |> Changeset.cast_changeset_params([ :annotation_id ])
    |> foreign_key_constraint(:annotation)
    |> Changeset.handle_annotation_id_change(state)
    |> Changeset.maybe_replace_annotation_params(last_change, state)
  # |> change element
    |> Changeset.cast_changeset_params([ :element_id ])
    |> foreign_key_constraint(:element)
    |> Changeset.handle_element_id_change(state)
    |> Changeset.maybe_replace_element_params(last_change, state)
  # |> update step fk's
    |> Changeset.cast_changeset_params([ :page_id, :annotation_id, :element_id ])
    |> Changeset.update_foreign_keys(action)
  # |> change content
    |> cast_assoc(:annotation, with: &Annotation.content_id_changeset/2)
    |> Changeset.handle_content_id_change(state)
    |> Changeset.maybe_replace_content_params(last_change, state)
  # |> update annotation fk's
    |> cast_assoc(:annotation, with: &Annotation.content_id_changeset/2)
    |> Changeset.update_foreign_keys(action)
  # |> final changes
    |> Changeset.cast_changeset_params([ :process_id, :step_type_id ])
    |> Changeset.cast_changeset_params([ :name, :order, :url, :text, :width, :height, :page_reference ])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:step_type)
    |> assoc_changeset()
    |> names_changeset()
    |> validate_required([:order])
  end

  def fields_changeset(step, attrs) do
    step
    |> cast(attrs, [ :order, :name, :url, :text, :width, :height, :page_reference ])
    |> cast(attrs, [ :process_id, :page_id, :element_id, :annotation_id, :step_type_id ])
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
  end

  def names_changeset(changeset) do
    changeset
    |> put_annotation_name()
    |> put_name()
  end

  def safe(step, handlers) do
    UserDocs.Automation.Step.Safe.apply(step, handlers)
  end

  def put_annotation_name(%{ data: %{ annotation: %Ecto.Association.NotLoaded{} }} = changeset), do: changeset
  def put_annotation_name(%{ data: %{ element: %Ecto.Association.NotLoaded{} }} = changeset), do: changeset
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
