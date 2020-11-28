defmodule UserDocs.Documents.Docubit do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger
  require Kernel

  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Docubit.Type
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Documents.Docubit.Preload
  alias UserDocs.Documents.Docubit.Renderer
  alias UserDocs.Documents.Docubit.Access
  alias UserDocs.Documents.Docubit.Hydrate

  alias UserDocs.Documents.DocumentVersion

  alias UserDocs.Documents.Content
  alias UserDocs.Media.File
  alias UserDocs.Web.Annotation
  alias UserDocs.Automation.Step

  @valid_settings [ :li_value, :name_prefix ]

  schema "docubits" do
    field :type_id, :string
    field :order, :integer
    field :settings, { :array, EctoKW }
    field :address, { :array, :integer }

    has_many :docubits, Docubit
    has_one :context, Context

    belongs_to :docubit, Docubit
    belongs_to :document_version, DocumentVersion
    belongs_to :content, Content
    belongs_to :file, File
    belongs_to :through_annotation, Annotation
    belongs_to :through_step, Step

    timestamps()
  end

  def internal_changeset(docubit, attrs \\ %{}) do
    docubit
    |> put_assoc(:content, Map.get(attrs, :content, nil))
    |> put_assoc(:through_annotation, Map.get(attrs, :through_annotation, nil))
    |> put_assoc(:through_step, Map.get(attrs, :through_step, nil))
  end

  def changeset(docubit, attrs \\ %{}) do
    docubit
    |> cast(attrs, [ :type_id, :settings, :address, :document_version_id, :content_id, :through_annotation_id, :through_step_id, :docubit_id ])
    |> cast_assoc(:docubits)
    |> (&(validate_change(&1, :docubits,
      fn(:docubits, docubits) ->
        validate_allowed_docubits(&1, docubits)
      end))).()
    |> cast_settings()
    |> order_docubits()
    |> address_docubits()
    |> validate_required([ :type_id ])
  end

  def order_docubits(changeset) do
    case get_change(changeset, :docubits) do
      nil -> changeset
      "" -> changeset
      docubits ->
        { docubits, order } =
          Enum.map_reduce(docubits, 0,
            fn(d, o) ->
              { put_change(d, :order, o), o + 1}
            end)

        Ecto.Changeset.put_change(changeset, :docubits, docubits)
    end
  end

  def address_docubits(changeset) do
    parent_address = get_field(changeset, :address)
    case get_change(changeset, :docubits) do
      nil -> changeset
      "" -> changeset
      docubits ->
        docubits
        |> update_docubits_addresses(parent_address)
        |> (&(Ecto.Changeset.put_change(changeset, :docubits, &1))).()
    end
  end

  def update_docubits_addresses(docubits, parent_address) do
    Enum.map(docubits,
    fn(docubit) ->
      case docubit.action do
        :replace -> docubit
        :update -> docubit
        :insert ->
          docubit
          |> get_field(:order)
          |> (&(List.insert_at(parent_address, -1, &1))).()
          |> (&(Ecto.Changeset.put_change(docubit, :address, &1))).()
      end
    end)
  end

  def validate_allowed_docubits(changeset, docubits) do
    Logger.debug("Validating docubits are allowed")
    type =
      changeset
      |> get_field(:type_id)
      |> String.to_atom()
      |> (&(Kernel.apply(Type, &1, []))).()

    Enum.reduce(docubits, [],
      fn(d, errors) ->
        case get_field(d, :type_id) in type.allowed_children do
          true -> errors
          false -> [ docubits: "This type may not be inserted into this docubit."]
        end
      end
    )
  end

  def print(%Docubit{} = docubit, padding \\ "") do
    type =
      try do
        docubit.type.name
      rescue
        _ -> docubit.type_id
      end

    children =
      docubit.docubits
      |> Enum.reduce("", fn(d, acc) -> acc <> print(d, padding <> "--") end)

    "#{padding}#{type}: #{inspect(docubit.address)}\n#{children}"
  end

  def print_changeset(changeset) do
    IO.inspect(changeset.changes)
    changeset
  end

  def cast_settings(%{changes: %{ settings: settings }} = changeset) do
    settings =
      Enum.reduce(settings, changeset.data.settings || [],
        fn({k, v}, s) ->
          if k in @valid_settings do
            Keyword.put_new(s, k, v)
          else
            raise(RuntimeError, "Tried to cast an invalid setting")
          end
        end)

    Ecto.Changeset.put_change(changeset, :settings, settings)
  end
  def cast_settings(changeset), do: changeset

  def context(docubit, parent_contexts), do: Context.context(docubit, parent_contexts)
  # Applies Contexts to the Docubit
  def apply_contexts(docubit, parent_contexts), do: Context.apply_context_changes(docubit, parent_contexts)

  # def preload(docubit, state), do: Preload.apply(docubit, state)
  def renderer(docubit = %Docubit{}), do: Renderer.apply(docubit)
  def hydrate(body, address, data), do: Hydrate.apply(body, address, data)

end
