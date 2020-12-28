defmodule UserDocs.Documents.Docubit do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger
  require Kernel

  alias UserDocs.Documents
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.DocubitType
  alias UserDocs.Documents.DocubitSetting
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Documents.Docubit.Renderer
  alias UserDocs.Documents.Docubit.Hydrate

  alias UserDocs.Documents.DocumentVersion

  alias UserDocs.Documents.Content
  alias UserDocs.Media.File
  alias UserDocs.Web.Annotation
  alias UserDocs.Automation.Step

  @valid_settings [ :li_value, :name_prefix ]

  schema "docubits" do
    field :order, :integer
    field :address, { :array, :integer }
    field :context, EctoContext

    embeds_one :settings, DocubitSetting, on_replace: :delete

    has_many :docubits, Docubit, on_delete: :delete_all

    belongs_to :docubit_type, DocubitType

    belongs_to :docubit, Docubit
    belongs_to :document_version, DocumentVersion
    belongs_to :content, Content
    belongs_to :file, File
    belongs_to :through_annotation, Annotation
    belongs_to :through_step, Step

    field :delete, :boolean, virtual: true
    timestamps()
  end

  defp mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end

  def internal_changeset(docubit, attrs \\ %{}) do
    docubit
    |> change(attrs)
    |> put_assoc(:docubits, Map.get(attrs, :docubits, nil))
    |> put_assoc(:content, Map.get(attrs, :content, nil))
    |> put_assoc(:through_annotation, Map.get(attrs, :through_annotation, nil))
    |> put_assoc(:through_step, Map.get(attrs, :through_step, nil))
    |> validate_required([ :docubit_type_id, :document_version_id ])
    |> check_for_deleted_docubits()
    |> order_changeset_docubits()
    |> address_docubits()
  end

  def changeset(docubit, attrs \\ %{}) do
    docubit
    |> cast(attrs, [ :delete, :docubit_type_id, :address,
        :document_version_id, :content_id, :through_annotation_id,
        :through_step_id, :docubit_id, :file_id, :context ])
    |> cast_embed(:settings)
    |> cast_assoc(:docubits)
    |> foreign_key_constraint(:docubit_type_id)
    |> foreign_key_constraint(:document_version_id)
    |> foreign_key_constraint(:content_id)
    |> foreign_key_constraint(:through_annotation_id)
    |> foreign_key_constraint(:through_step_id)
    |> (&(validate_change(&1, :docubits,
      fn(:docubits, docubits) ->
        validate_allowed_docubits(&1, docubits)
      end))).()
    |> order_changeset_docubits()
    |> address_docubits()
    |> validate_required([ :docubit_type_id, :document_version_id ])
    |> mark_for_deletion()
  end

  defp check_for_deleted_docubits(changeset) do
    case get_change(changeset, :docubits) do
      nil -> changeset
      docubits ->
        put_change(changeset, :docubits, Enum.map(docubits, &mark_for_deletion/1))
    end
  end

  def order_changeset_docubits(changeset) do
    case get_change(changeset, :docubits) do
      nil -> changeset
      "" -> changeset
      docubits ->
        ordered_docubits = order_docubits(docubits, 0, &put_change/3)
        Ecto.Changeset.put_change(changeset, :docubits, ordered_docubits)
    end
  end

  def order_docubits(docubits, init, change_function \\ &put_change/3) do
    { docubits, _ } =
      Enum.map_reduce(docubits, init,
        fn(d, o) ->
          case d.action do
            :delete -> { change_function.(d, :order, o), o}
            _ -> { change_function.(d, :order, o), o + 1}
          end
        end)
    docubits
  end

  def address_docubits(changeset) do
    parent_address = get_field(changeset, :address)
    case get_change(changeset, :docubits) do
      nil -> changeset
      "" -> changeset
      docubits ->
        docubits
        |> update_docubits_addresses(parent_address, &put_change/3)
        |> (&(Ecto.Changeset.put_change(changeset, :docubits, &1))).()
    end
  end

  def update_docubits_addresses(docubits, parent_address, change_function) do
    Enum.map(docubits,
    fn(docubit) ->
      case docubit.action do
        :delete -> Map.put(docubit, :address, nil)
        :replace -> docubit
        :update -> change_docubit_address(docubit, parent_address, change_function)
        :insert -> change_docubit_address(docubit, parent_address, change_function)
      end
    end)
  end

  def change_docubit_address(docubit, parent_address, change_function) do
    docubit
    |> get_field(:order)
    |> (&(List.insert_at(parent_address, -1, &1))).()
    |> (&(change_function.(docubit, :address, &1))).()
  end

  def validate_allowed_docubits(changeset, docubits) do
    Logger.debug("Validating docubits are allowed")
    type =
      changeset
      |> get_field(:docubit_type)

    Enum.reduce(docubits, [],
      fn(d, errors) ->
        type_name = Documents.get_docubit_type!(get_field(d, :docubit_type_id)) |> Map.get(:name) # TODO: Get this in memory
        case type_name in type.allowed_children do
          true -> errors
          false -> [ docubits: "This type may not be inserted into docubit #{inspect(changeset)}."]
        end
      end
    )
  end

  def print(%Docubit{} = docubit, padding \\ "") do
    type =
      try do
        docubit.docubit_type.name
      rescue
        _ -> docubit.type_id
      end

    children =
      docubit.docubits
      |> Enum.reduce("", fn(d, acc) -> acc <> print(d, padding <> "--") end)

    "#{padding}#{type}: #{inspect(docubit.address)}\n#{children}"
  end

  def print_changeset(changeset) do
    IO.inspect(changeset.data)
    changeset
  end

  def context(docubit, parent_context), do: Context.context(docubit, parent_context)
  # Applies context to the Docubit
  def apply_context(docubit, parent_context), do: Context.apply_context_changes(docubit, parent_context)

  # def preload(docubit, state), do: Preload.apply(docubit, state)
  def renderer(docubit = %Docubit{}), do: Renderer.apply(docubit)
  def hydrate(docubit, data), do: Hydrate.apply(docubit, data)

  def preload_type(docubit) do
    docubit
    |> Map.put(:type, type(docubit))
  end

  defp type(docubit) do
    Type.types()
    |> Enum.filter(fn(t) -> t.id == docubit.type_id end)
    |> Enum.at(0)
  end
end
