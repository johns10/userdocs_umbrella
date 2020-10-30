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

  def inspect_changeset(changeset) do
    IO.inspect(changeset.data)
    changeset
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
    |> cast_assocs()
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
    |> inspect_changeset()
    |> cast_assocs()
    |> validate_assoc_action()
    |> put_annotation_name()
    |> put_name()
    |> cast(attrs, [ :name ])
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

  def foreign_key_constraints(step) do
    step
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:page)
    |> foreign_key_constraint(:element)
    |> foreign_key_constraint(:annotation)
    |> foreign_key_constraint(:step_type)
  end

  def cast_assocs(step) do
    step
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> cast_assoc(:page)
  end


  def validate_assoc_action(changeset) do
    Logger.debug("validate_assoc_action")
    changeset
    |> validate_action(:annotation)
    |> validate_action(:element)
  end

  def validate_action(changeset, key) do
    Logger.debug("Validating action for #{key}")
    maybe_update_action(changeset, changeset.changes[key], key)
  end

  def maybe_update_action(changeset, nil, _), do: changeset
  def maybe_update_action(
    changeset, %{ action: :insert, data: %{ id: nil }} = nested_changeset, key
  ) do
    changeset
  end
  def maybe_update_action(
    changeset, %{ action: :update, data: %{ id: nil }} = nested_changeset, key
  ) do
    Logger.warn("Automation.update_step caught update action with nil id")
    update_nested_action(changeset, nested_changeset, key, :insert)
  end
  def maybe_update_action(
    changeset, %{ action: :insert, data: %{ id: id }} = nested_changeset, key
  ) when is_integer(id) do
    Logger.warn("Automation.update_step caught insert action with integer id")
    update_nested_action(changeset, nested_changeset, key, :update)
  end

  def update_nested_action(changeset, nested_changeset, key, action) do
    nested_changes = Map.put(nested_changeset, :action, action)
    changes = Map.put(changeset.changes, key, nested_changes)
    Map.put(changeset, :changes, changes)
  end


  def handle_changes(changes, state) do
    UserDocs.Automation.Step.ChangeHandler.execute(changes, state)
  end

  def safe(annotation, handlers \\ %{})
  def safe(step = %UserDocs.Automation.Step{}, handlers) do
    element_handlers = %{
      strategy: handlers.strategy
    }
    base_safe(step)
    |> maybe_safe_step_type(handlers[:step_type], step.step_type, handlers)
    |> maybe_safe_annotation(handlers[:annotation], step.annotation, handlers)
    |> maybe_safe_element(handlers[:element], step.element, element_handlers)
    |> maybe_safe_screenshot(handlers[:screenshot], step.screenshot, handlers)
    |> maybe_safe_page(handlers[:page], step.page, handlers)
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

  def maybe_safe_page(step, nil, _, _), do: step
  def maybe_safe_page(step, handler, page, handlers) do
    Map.put(step, :page, handler.(page, handlers))
  end

  def put_annotation_name(changeset) do
    case Ecto.Changeset.apply_action(changeset, :update) do
      { :ok, step } ->
        name =
          UserDocs.Web.Annotation.Name.execute(
            step.annotation, step.element)

        Logger.debug("Putting Annotation Name #{name}")

        changeset = Ecto.Changeset.update_change(changeset, :annotation,
          fn(a) -> Ecto.Changeset.put_change(a, :name, name) end)

        changeset

      { :error, changeset } -> changeset
    end
  end

  def put_name(changeset) do
    case Ecto.Changeset.apply_action(changeset, :update) do
      { :ok, step } ->
        name = Name.execute(step)
        # Logger.debug("Putting Step Name #{name}")
        Ecto.Changeset.put_change(changeset, :name, name)

      { :error, changeset } -> changeset
    end
  end

  def name(step = %UserDocs.Automation.Step{}) do
    Name.execute(step)
  end
end
