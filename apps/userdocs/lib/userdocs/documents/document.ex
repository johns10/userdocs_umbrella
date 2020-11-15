defmodule UserDocs.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Projects.Version
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.Document.MapDocubits

  @state_opts %{ data_type: :map, strategy: :by_key, location: :root }

  schema "documents" do
    field :name, :string
    field :title, :string
    field :map, { :map, :integer }

    belongs_to :version, Version
    belongs_to :body, Docubit, foreign_key: :docubit_id

    has_many :docubits, Docubit

    timestamps()
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [ :name, :title, :version_id, :docubit_id ])
    |> body_is_container_docubit_if_empty()
    |> cast_assoc(:body, with: &Docubit.changeset/2)
    |> foreign_key_constraint(:version_id)
    |> foreign_key_constraint(:docubit_id)
    |> validate_required([:name, :title])
  end

  defp body_is_container_docubit_if_empty(changeset) do
    attrs = %{ type_id: "container", address: [0] }

    case get_change(changeset, :docubit_id) do
      nil -> put_change(changeset, :body, attrs)
      "" -> put_change(changeset, :body, attrs)
      _ -> changeset
    end
  end

  def map_docubits(%Document{ docubits: _ } = document), do: MapDocubits.apply(document)

  alias UserDocs.Documents.Docubit

  def load(%Document{ docubits: docubits } = document, state) do
    docubits = Enum.map(docubits, fn(d) -> Docubit.preload(d, state) end)
    state = State.load(state, docubits, @state_opts)
    map = Document.map_docubits(document)
    IO.inspect(traverse_docubit_map(map, state))
  end

  def traverse_docubit_map(map, state) do
    Enum.each(map,
    fn(i) ->
      docubit_map_item(i, state)
    end)
  end
  def docubit_map_item({ key, map }, state) do
    IO.puts("The item is #{map.id}")
    IO.puts("It's children are:")
    opts = Map.put(@state_opts, :type, "docubit")
    docubit = State.get(state, map.id, opts)
    Docubit.context(docubit, %{})
    Enum.each(Map.delete(map, :id) , fn(i) ->
      docubit_map_item(i, state)
    end)
  end
end
