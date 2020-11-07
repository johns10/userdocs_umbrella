defmodule UserDocs.Documents.NewDocubit do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  alias UserDocs.Documents.NewDocubit, as: Docubit
  alias UserDocs.Documents.Docubit.Type
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Documents.Docubit.Preload
  alias UserDocs.Documents.Docubit.Renderer

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
    embeds_many :docubits, UserDocs.Documents.NewDocubit, on_replace: :delete

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

    "#{padding}#{type}\n#{children}"
  end

  def print_changeset(changeset) do
    IO.inspect(changeset.changes)
    changeset
  end

  def changeset(docubit, attrs \\ %{}) do
    docubit
    |> cast(attrs, [ :settings, :address ])
    |> cast_settings()
    |> embed_type()
  end

  def change_docubits(docubit, attrs) do
    IO.puts("changing Docubit")
    docubit
    |> change(attrs)
    |> validate_change(:docubits,
      fn(:docubits, docubits) ->
        validate_allowed_docubits(docubit, docubits)
      end)
    |> validate_change(:address,
      fn(:address, address) ->
        IO.puts("validating address")
        IO.inspect(address)
      end
    )
  end

  def validate_allowed_docubits(docubit, docubits) do
    # Logger.debug("Validating docubits are allowed for #{inspect(docubit.type.allowed_children)}")
    Enum.reduce(docubits, [],
      fn(d, errors) ->
        case d.data.type_id in docubit.type.allowed_children do
          true -> errors
          false -> [ docubits: "This type may not be inserted into this docubit."]
        end
      end
    )
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

  def update(_, [0], _docubit) do
    raise(RuntimeError, "Can't update the document body")
  end
  def update(
    %Docubit{ address: [0], type: %Type{ id: "container" }} = body,
    [ 0 | address ], docubit
  ) do
    Logger.debug("Updating docubit #{docubit.type_id} at address #{inspect(address)}")
    fetch_and_replace(body, address, docubit, &final_update/3)
  end

  def insert(_, [0], _docubit) do
    raise(RuntimeError, "Can't replace the document body directly")
  end
  def insert(
    %Docubit{ address: [0], type: %Type{ id: "container" }} = body,
    [ 0 | address ], docubit
  ) do
    Logger.debug("Putting docubit #{docubit.type_id} at address #{inspect(address)}")
    fetch_and_replace(body, address, docubit, &temp_insert/3)
  end

  def get(%Docubit{ address: [0], type: %Type{ id: "container" }} = body, [0]), do: body
  def get(%Docubit{ address: [0], type: %Type{ id: "container" }} = body, [0 | address]) do
    fetch(body, address)
  end

  def temp_insert([ %Docubit{} | _ ] = docubits, index, new_docubit) do
    final_insert(docubits, index, new_docubit)
  end
  def temp_insert([] = docubits, index, new_docubit) do
    final_insert(docubits, index, new_docubit)
  end
  def final_insert(docubits, index, new_docubit) do
    docubits
    |> List.insert_at(index, new_docubit)
  end

  def temp_update([ %Docubit{} | _ ] = docubits, index, new_docubit) do
    final_insert(docubits, index, new_docubit)
  end
  def temp_update([] = docubits, index, new_docubit) do
    final_insert(docubits, index, new_docubit)
  end
  def final_update(docubits, index, new_docubit) do
    docubits
    |> List.update_at(index, fn(_) -> new_docubit end)
  end

  def fetch_and_replace(docubit, [ index | [] ], new_docubit, final_op) do
    Logger.debug("Fetching Single Element from #{docubit.type_id} at index #{index}")

    with docubits <- Map.get(docubit, :docubits),
      docubits <- final_op.(docubits, index, new_docubit),
      changeset <- Docubit.change_docubits(docubit, %{ docubits: docubits }),
      { status, updated_docubit } <- Ecto.Changeset.apply_action(changeset, :update)
    do
      case status do
        :error -> { status, docubit, updated_docubit.errors }
        :ok -> { status, updated_docubit, [] }
      end
    else
      _ -> raise(RuntimeError, "Docubit.fetch_and_replace (single) failed")
    end

  end
  def fetch_and_replace(docubit, [ index | address ], new_docubit, final_op) do
    Logger.debug("Fetching Multi Element List from #{docubit.type_id} at address #{inspect(address)}")

    with docubits <- Map.get(docubit, :docubits),
      docubit_to_update <- fetch(docubit, index),
      { status, updated_docubit, errors }
        <- fetch_and_replace(docubit_to_update, address, new_docubit, final_op),

      updated_docubits
        <- List.update_at(docubits, index, fn(_) -> updated_docubit end)
    do
      case status do
        :ok -> { :ok, Map.put(docubit, :docubits, updated_docubits), errors }
        :error -> { :error, docubit, errors }
      end
    else
      _ -> raise(RuntimeError, "Docubit.fetch_and_replace (multiple) failed")
    end
  end

  def fetch(docubit, [ index | [] ]), do: fetch(docubit, index)
  def fetch(docubit, [ index | address ]) do
    Logger.debug("Multi Element List: #{docubit.type_id}")
    docubit
    |> fetch(index)
    |> fetch(address)
  end
  def fetch(docubit, index) when is_integer(index) do
    Logger.debug("Single Element List: #{docubit.type_id}")
    docubit
    |> Map.get(:docubits)
    |> Enum.at(index)
  end

end
