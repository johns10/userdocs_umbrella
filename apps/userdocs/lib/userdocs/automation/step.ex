defmodule UserDocs.Automation.Step do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  alias UserDocs.Documents
  alias UserDocs.Documents.Content
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

  def change_nested_foreign_keys(step, attrs) do
    #IO.puts("change_nested_foreign_keys")
    step
    |> cast(attrs, [ :page_id, :element_id, :annotation_id ])
    |> foreign_key_constraint(:page)
    |> foreign_key_constraint(:element)
    |> foreign_key_constraint(:annotation)
  end

  def change_remaining(step, attrs) do
   #IO.puts("change_remaining")
    step
    |> cast(attrs, [ :process_id, :step_type_id ])
    |> cast(attrs, [ :name, :order, :url, :text, :width, :height, :page_reference ])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:step_type)
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> cast_assoc(:page)
    |> put_annotation_name()
    |> put_name()
  end

  def validate_action(changeset) do
    UserDocs.Automation.Step.Action.validate(changeset)
  end

  def validate_assoc_action(changeset) do
    UserDocs.Automation.Step.Action.validate_assoc(changeset)
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

  alias UserDocs.Web

  def changeset_two(step, last_step, attrs, state, action) do
    last_change = changeset(last_step, attrs)
    step
  # |> change page
    |> cast(attrs, [ :page_id ])
    |> foreign_key_constraint(:page)
    |> handle_page_id_change(state)
    |> maybe_replace_page_params(last_change, state)
  # |> change annotation
    |> cast_changeset_params([ :annotation_id ])
    |> foreign_key_constraint(:annotation)
    |> handle_annotation_id_change(state)
    |> maybe_replace_annotation_params(last_change, state)
  # |> change element
    |> cast_changeset_params([ :element_id ])
    |> foreign_key_constraint(:element)
    |> handle_element_id_change(state)
    |> maybe_replace_element_params(last_change, state)
  # |> update step fk's
    |> cast_changeset_params([ :page_id, :annotation_id, :element_id ])
    |> update_foreign_keys(action)
  # |> change content
    |> cast_assoc(:annotation, with: &Annotation.content_id_changeset/2)
    |> handle_content_id_change(state)
    |> maybe_replace_content_params(last_change, state)
  # |> update annotation fk's
    |> cast_assoc(:annotation, with: &Annotation.content_id_changeset/2)
    |> update_foreign_keys(action)
  # |> final changes
    |> cast_changeset_params([ :process_id, :step_type_id ])
    |> cast_changeset_params([ :name, :order, :url, :text, :width, :height, :page_reference ])
    |> foreign_key_constraint(:process)
    |> foreign_key_constraint(:step_type)
    |> cast_assoc(:element)
    |> cast_assoc(:annotation)
    |> cast_assoc(:page)
    |> put_annotation_name()
    |> put_name()
  end

  def inspect_content_id_changes(changeset) do
    log_string =
      "Content ID: #{changeset.data.annotation |> Map.get(:content_id, nil)}, param: #{changeset.params["annotation"] |> Map.get("content_id", nil)}"
    IO.puts(log_string)
    IO.inspect(changeset.changes)
    changeset
  end

  def inspect_params(changeset) do
    IO.inspect(changeset.params)
    changeset
  end

  def inspect_changeset(changeset) do
    IO.puts("Final Changes")
    IO.inspect(changeset.changes)
    IO.puts("Final params")
    IO.inspect(changeset.params)
    changeset
  end

  def handle_page_id_change(%{ changes: %{ page_id: page_id }} = changeset, state) do
    IO.puts("Page id changed to #{page_id}")
    page = Web.get_page!(page_id, state, state.assigns.state_opts)
    Map.put(changeset.data, :page, page)
    |> cast(changeset.params, [ ])
  end
  def handle_page_id_change(changeset, _state), do: changeset

  def maybe_replace_page_params(changeset, %{ changes: %{ page_id: page_id }}, state) do
    IO.puts("Replacing Page #{page_id} Params")
    page = Web.get_page!(page_id, state, state.assigns.state_opts)
    page_params = replace_params_with_fields(changeset.params["page"], page, Page)
    params =
      changeset.params
      |> Map.put("page", page_params)
      |> Map.put("page_id", Integer.to_string(page_id))

    Map.put(changeset, :params, params)
  end
  def maybe_replace_page_params(changeset, _last_changeset, _state), do: changeset

  def handle_annotation_id_change(%{ changes: %{ annotation_id: annotation_id }} = changeset, state) do
    IO.puts("Annotation id changed to #{annotation_id}")
    opts = Keyword.put(state.assigns.state_opts, :preloads, [ :content, :annotation_type ])
    annotation = Web.get_annotation!(annotation_id, state, opts)

    Map.put(changeset.data, :annotation, annotation)
    |> cast(changeset.params, [ ])
  end
  def handle_annotation_id_change(changeset, _state), do: changeset

  def maybe_replace_annotation_params(changeset, %{ changes: %{ annotation_id: annotation_id }}, state) do
    IO.puts("Replacing Annotation #{annotation_id} Params")
    opts = Keyword.put(state.assigns.state_opts, :preloads, [ :content, :annotation_type ])
    annotation = Web.get_annotation!(annotation_id, state, opts)
    annotation_params = replace_params_with_fields(changeset.params["annotation"], annotation, Annotation)
    params =
      changeset.params
      |> Map.put("annotation", annotation_params)
      |> Map.put("annotation_id", Integer.to_string(annotation_id))

    Map.put(changeset, :params, params)
  end
  def maybe_replace_annotation_params(changeset, _last_changeset, _state), do: changeset

  def handle_element_id_change(%{ changes: %{ element_id: element_id }} = changeset, state) do
    IO.puts("Element id changed to #{element_id}")
    element = Web.get_element!(element_id, state, state.assigns.state_opts)
    Map.put(changeset.data, :element, element)
    |> cast(changeset.params, [ ])
  end
  def handle_element_id_change(changeset, _state) do
    changeset
    |> cast(changeset.params, [ :page_id, :element_id, :annotation_id])
  end

  def maybe_replace_element_params(changeset, %{ changes: %{ element_id: element_id }}, state) do
    IO.puts("Replacing Element params")
    element = Web.get_element!(element_id, state, state.assigns.state_opts)
    element_params = replace_params_with_fields(changeset.params["element"], element, Element)
    params =
      changeset.params
      |> Map.put("element", element_params)
      |> Map.put("element_id", Integer.to_string(element_id))

    Map.put(changeset, :params, params)
  end
  def maybe_replace_element_params(changeset, _last_changeset, _state), do: changeset

  def handle_content_id_change(%{ changes: %{ annotation: %{ changes: %{ content_id: nil }}}} = changeset, _state), do: changeset
  def handle_content_id_change(
    %{ changes: %{ annotation: %{ changes: %{ content_id: content_id }}}} = changeset, state
  ) do
    IO.puts("Content id changed to #{content_id}")
    content = Documents.get_content!(content_id, state, state.assigns.state_opts)
    step = changeset.data
    annotation = Map.put(step.annotation, :content, content)
    Map.put(step, :annotation, annotation)
    |> cast(changeset.params, [])
  end
  def handle_content_id_change(changeset, _state) do
    changeset
  end

  def maybe_replace_content_params(changeset, %{ changes: %{ annotation: %{ changes: %{ content_id: nil }}}}, _state), do: changeset
  def maybe_replace_content_params(
    changeset, %{ changes: %{ annotation: %{ changes: %{ content_id: content_id }}}}, state
  ) do
    IO.inspect("Replace Content Params")
    content = Documents.get_content!(content_id, state, state.assigns.state_opts)
    annotation_params = changeset |> Map.get(:params) |> Map.get("annotation")
    content_params = annotation_params |> Map.get("content") |> replace_params_with_fields(content, Content)
    params =
      changeset.params
      |> Kernel.put_in([ "annotation", "content" ], content_params)
      |> Kernel.put_in([ "annotation", "content_id" ], Integer.to_string(content_id))

    Map.put(changeset, :params, params)
  end
  def maybe_replace_content_params(changeset, _last_changeset, _state), do: changeset

  def update_foreign_keys(changeset, action) do
    _log_string = """
      Updating Foreign Keys.
      Annotation ID: #{changeset.data.annotation_id}, param: #{changeset.params["annotation_id"]}
      Element ID: #{changeset.data.element_id}, param: #{changeset.params["element_id"]}
      Page ID: #{changeset.data.page_id}, param: #{changeset.params["page_id"]}
    """
    #Content ID: #{changeset.data |> Map.get(:annotation, %{ content_id: nil }) |> Map.get(:content_id, nil)}, param: #{changeset.params |> Map.get("annotation", %{ "content_id" => nil }) |> Map.get("content_id", nil)}

    case action do
      :validate ->
        { :ok, step } = apply_action(changeset, :update)
        step
        |> cast(changeset.params, [ ])
      _ ->
        { :ok, step } = UserDocs.Repo.update(changeset)
        step
        |> cast(changeset.params, [ ])
    end
  end

  def replace_params_with_fields(nil, object, module) do
    replace_params_with_fields(%{}, object, module)
  end
  def replace_params_with_fields(params, nil, _module), do: params
  def replace_params_with_fields(params, object, module) do
    Enum.reduce(module.__schema__(:fields), params,
      fn(field, params) ->
        Map.put(params, to_string(field), Map.get(object, field))
      end
    )
  end

  def cast_changeset_params(changeset, allowed) do
    changeset
    |> cast(changeset.params, allowed)
  end
end
