defmodule UserDocs.Documents.NewDocubit do
  use Ecto.Schema
  import Ecto.Changeset

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
    embeds_many :docubits, UserDocs.Documents.NewDocubit

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

  def changeset(docubit, attrs \\ %{}) do
    IO.inspect("docubit changeset")
    docubit
    |> cast(attrs, [ :settings, :address ])
    |> cast_settings()
    |> embed_type()
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
    IO.puts("Embedding type")
    IO.inspect(changeset)
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

  def insert(_, [0], docubit) do
    raise(RuntimeError, "Can't replace the document body directly")
  end
  def insert(
    %Docubit{ address: [0], type: %Type{ id: "container" }} = body,
    [ 0 | address ], docubit
  ) do
    IO.puts("Putting docubit #{docubit.type_id} at address #{inspect(address)}")
    fetch_and_insert(body, address, docubit)
  end

  def get(%Docubit{ address: [0], type: %Type{ id: "container" }} = body, [0]), do: body
  def get(%Docubit{ address: [0], type: %Type{ id: "container" }} = body, [0 | address]) do
    fetch(body, address)
  end

  def fetch_and_insert(docubit, [ index | [] ], new_docubit) do
    IO.inspect("Fetching Single Element from #{docubit.type_id} at index #{index}")
    docubit
    |> Map.get(:docubits)
    |> List.insert_at(index, new_docubit)
    |> (&(Map.put(docubit, :docubits, &1))).()
  end
  def fetch_and_insert(docubit, [ index | address ], new_docubit) do
    IO.inspect("Fetching Multi Element List from #{docubit.type_id} at address #{inspect(address)}")
    updated_docubit =
      docubit
      |> fetch(index)
      |> fetch_and_insert(address, new_docubit)

    docubit
    |> Map.get(:docubits)
    |> List.update_at(index, fn(_) -> updated_docubit end)
    |> (&(Map.put(docubit, :docubits, &1))).()
  end

  def fetch(docubit, [ index | [] ]), do: fetch(docubit, index)
  def fetch(docubit, [ index | address ]) do
    # IO.inspect("Multi Element List: #{docubit.type_id}")
    docubit
    |> fetch(index)
    |> fetch(address)
  end
  def fetch(docubit, index) when is_integer(index) do
    docubit
    |> Map.get(:docubits)
    |> Enum.at(index)
  end

end
