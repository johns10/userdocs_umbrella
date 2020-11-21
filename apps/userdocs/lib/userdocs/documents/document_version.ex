defmodule UserDocs.Documents.DocumentVersion do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Projects.Version
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Documents.Document.MapDocubits
  alias UserDocs.Documents.Docubit.Context

  @state_opts [ data_type: :map, strategy: :by_key, location: :root ]

  schema "document_versions" do
    field :name, :string
    field :map, { :map, :integer }

    belongs_to :document, Document
    belongs_to :version, Version
    belongs_to :body, Docubit, foreign_key: :docubit_id

    has_many :docubits, Docubit

    timestamps()
  end

  @doc false
  def changeset(document_version, attrs) do
    document_version
    |> cast(attrs, [ :name, :version_id, :docubit_id ])
    |> body_is_container_docubit_if_empty()
    |> cast_assoc(:body, with: &Docubit.changeset/2)
    |> foreign_key_constraint(:version_id)
    |> foreign_key_constraint(:docubit_id)
  end

  defp body_is_container_docubit_if_empty(changeset) do
    attrs = %{ type_id: "container", address: [0] }

    case get_field(changeset, :docubit_id) do
      nil -> put_change(changeset, :body, attrs)
      "" -> put_change(changeset, :body, attrs)
      _ -> changeset
    end
  end

  def map_docubits(%DocumentVersion{ docubits: _ } = document_version), do: MapDocubits.apply(document_version)

  alias UserDocs.Documents.Docubit

  def load(%DocumentVersion{ docubits: docubits } = document_version, state) do
    docubits = Enum.map(docubits, fn(d) -> Docubit.preload(d, state) end)
    state = StateHandlers.load(state, docubits, @state_opts)
    map =
      document_version
      |> MapDocubits.apply()

    traverse_docubit_map(map, state)
  end

  def traverse_docubit_map(map, state) do
    docubit_map_item({ 0, Map.get(map, 0) }, state, %Context{})
  end
  def docubit_map_item({ _key, map }, state, parent_context) do
    opts = Keyword.put(@state_opts, :type, "docubit")
    docubit = StateHandlers.get(state, map.docubit.id, opts)
    { :ok, context } = Docubit.context(docubit, parent_context)
    docubits =
      Enum.map(map.docubit.docubits,
        fn({ address, docubit }) ->
          docubit_map_item({ address, docubit }, state, context)
        end
      )
    docubit
    |> Map.put(:context, context)
    |> Map.put(:docubits, docubits)
  end

  def update_docubit_item(map, state, context) do
    Enum.reduce(map.docubit.docubits, map,
      fn({ address, item }, map) ->
        Kernel.put_in(map,
          [ :docubit, :docubits, address ],
          docubit_map_item({ address, item }, state, context)
        )
      end
    )
  end
end
