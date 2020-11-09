defmodule UserDocs.Documents.Docubit do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger
  require Kernel

  alias UserDocs.Documents.Docubit, as: Docubit
  alias UserDocs.Documents.Docubit.Type
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Documents.Docubit.Preload
  alias UserDocs.Documents.Docubit.Renderer
  alias UserDocs.Documents.Docubit.Access
  alias UserDocs.Documents.Docubit.Hydrate

  alias UserDocs.Documents.Content
  alias UserDocs.Media.File
  alias UserDocs.Web.Annotation
  alias UserDocs.Automation.Step

  @valid_settings [ :li_value, :name_prefix ]

  @primary_key :false
  schema "docubits" do
    field :settings, {:array, EctoKW}
    field :address, {:array, :integer}

    field :type_id, :string
    embeds_one :type, Type
    embeds_many :docubits, UserDocs.Documents.Docubit, on_replace: :delete

    belongs_to :content, Content
    belongs_to :file, File

    belongs_to :through_annotation, Annotation
    belongs_to :through_step, Step
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

  def changeset(docubit, attrs \\ %{}) do
    docubit
    |> cast(attrs, [ :settings, :address, :content_id, :through_annotation_id, :through_step_id ])
    |> put_assoc(:content, Map.get(attrs, :content, nil))
    |> put_assoc(:through_annotation, Map.get(attrs, :through_annotation, nil))
    |> put_assoc(:through_step, Map.get(attrs, :through_step, nil))
    |> cast_settings()
    |> embed_type()
  end

  def change_docubits(docubit, attrs) do
    docubit
    |> change(attrs)
    |> validate_change(:docubits,
      fn(:docubits, docubits) ->
        validate_allowed_docubits(docubit, docubits)
      end)
    |> address_docubits(docubit.address)
  end

  def validate_allowed_docubits(docubit, docubits) do
    Logger.debug("Validating docubits are allowed for #{inspect(docubit.type.allowed_children)}")
    Enum.reduce(docubits, [],
      fn(d, errors) ->
        case d.data.type_id in docubit.type.allowed_children do
          true -> errors
          false -> [ docubits: "This type may not be inserted into this docubit."]
        end
      end
    )
  end

  def address_docubits(changeset, parent_address) do
    case get_change(changeset, :docubits) do
      nil -> changeset
      "" -> changeset
      docubits ->
        docubits = update_docubits_addresses(docubits, parent_address)
        Ecto.Changeset.put_change(changeset, :docubits, docubits)
    end
  end

  def update_docubits_addresses(docubits, parent_address) do
    { updated_docubits, _ } =
      Enum.map_reduce(docubits, 0,
      fn(docubit, new_address) ->
        case docubit.action do
          :replace -> { docubit, new_address }
          :insert ->
            address = List.insert_at(parent_address, -1, new_address)
            {
              Ecto.Changeset.put_change(docubit, :address, address),
              new_address + 1
            }
        end
      end)

    updated_docubits
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

  defp embed_type(changeset) do
    case get_change(changeset, :type_id) do
      nil -> changeset
      "" -> changeset
      type_id ->
        type = Enum.filter(Type.types_attrs(), fn(t) -> t.id == type_id end)
        put_change(changeset, :type, type)
    end
  end

  # Applies all Contexts to a docubit.  Takes a docubit, returns a
  # Docubit with parent, type, and local contexts applied to the
  # Docubit
  def apply_contexts(docubit, parent_contexts), do: Context.apply(docubit, parent_contexts)
  def preload(docubit, state), do: Preload.apply(docubit, state)
  def renderer(docubit = %Docubit{}), do: Renderer.apply(docubit)
  def get(docubit = %Docubit{}, address), do: Access.get(docubit, address)
  def delete(docubit = %Docubit{}, address, old_docubit = %Docubit{}) do
    Access.delete(docubit, address, old_docubit)
  end
  def insert(docubit = %Docubit{}, address, new_docubit = %Docubit{}) do
    Access.insert(docubit, address, new_docubit)
  end
  def update(docubit = %Docubit{}, address, new_docubit = %Docubit{}) do
    Access.update(docubit, address, new_docubit)
  end
  def hydrate(body, address, data), do: Hydrate.apply(body, address, data)

end
