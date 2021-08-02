defmodule UserDocs.Documents.DocumentVersion do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Documents
  alias UserDocs.ChangesetHelpers
  alias UserDocs.Projects.Version
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Documents.Document.MapDocubits
  alias UserDocs.Documents.Docubit.Context

  schema "document_versions" do
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    field :name, :string
    field :map, {:map, :integer}

    belongs_to :document, Document
    belongs_to :version, Version
    belongs_to :body, Docubit, foreign_key: :docubit_id

    has_many :docubits, Docubit

    timestamps()
  end

  @doc false
  def changeset(document_version, attrs) do
    document_version
    |> Map.put(:temp_id, (document_version.temp_id || attrs["temp_id"]))
    |> cast(attrs, [:name, :document_id, :version_id, :docubit_id, :delete])
    |> body_is_container_docubit_if_empty()
    |> cast_assoc(:body, with: &Docubit.changeset/2)
    |> foreign_key_constraint(:version_id)
    |> foreign_key_constraint(:docubit_id)
    |> foreign_key_constraint(:document_id)
    |> ChangesetHelpers.maybe_mark_for_deletion()
  end

  defp body_is_container_docubit_if_empty(changeset) do
    container_type = Documents.get_docubit_type!("container")
    attrs = %{docubit_type_id: container_type.id, address: [0]}

    case get_field(changeset, :docubit_id) do
      nil -> put_change(changeset, :body, attrs)
      "" -> put_change(changeset, :body, attrs)
      _ -> changeset
    end
  end

  def map_docubits(%DocumentVersion{docubits: _} = document_version), do: MapDocubits.apply(document_version)
  def add_docubit_to_map(map, %Docubit{address: _} = docubit), do: MapDocubits.add_to_map(map, docubit)

  alias UserDocs.Documents.Docubit

  def load(%DocumentVersion{docubits: _} = document_version, state, opts) do
    # preloads = [:content, :through_annotation]
    map = MapDocubits.apply(document_version)

    Map.put(document_version, :body, traverse_docubit_map(map, state, opts))
  end

  def traverse_docubit_map(map, state, opts) do
    docubit_map_item({0, Map.get(map, 0)}, state, %Context{}, opts)
  end
  def docubit_map_item({_key, map}, state, parent_context, opts) do
    docubit = StateHandlers.get(state, map.docubit.id, Docubit, opts)
    {:ok, context} = Docubit.context(docubit, parent_context)
    docubits =
      Enum.map(map.docubit.docubits,
        fn({address, docubit}) ->
          docubit_map_item({address, docubit}, state, context, opts)
        end
      )
    docubit
    |> Map.put(:context, context)
    |> Map.put(:docubits, docubits)
  end

  def update_docubit_item(map, state, context, opts) do
    Enum.reduce(map.docubit.docubits, map,
      fn({address, item}, map) ->
        Kernel.put_in(map,
          [:docubit, :docubits, address],
          docubit_map_item({address, item}, state, context, opts)
        )
      end
    )
  end
end
