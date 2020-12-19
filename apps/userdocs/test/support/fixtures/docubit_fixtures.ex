defmodule UserDocs.DocubitFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Documents.Docubit, as: Docubit

  alias UserDocs.Documents
  alias UserDocs.Documents.DocubitType

  def state(state, opts) do
    opts =
      opts
      |> Keyword.put(:types, [ Docubit ])

    dv = Documents.list_document_versions(state, opts) |> Enum.at(0)
    p_type = Documents.get_docubit_type!(state, "p", opts)
    docubit = docubit(:p, dv.id, p_type.id)

    state
    |> StateHandlers.initialize(opts)
    |> StateHandlers.load([docubit], Docubit, opts)
  end

  def docubit_types(state, opts) do
    opts =
      opts
      |> Keyword.put(:types, [ DocubitType ])

    docubit_types = create_docubit_types()

    state
    |> StateHandlers.initialize(opts)
    |> StateHandlers.load(docubit_types, DocubitType, opts)
  end

  def docubit(type, state, opts) when is_list(opts) do
    dv = Documents.list_document_versions(state, opts) |> Enum.at(0)
    docubit_type = Documents.get_docubit_type!(state, Atom.to_string(type), opts)
    docubit(type, dv.id, docubit_type.id)
  end
  def docubit(type, document_version_id \\ nil, docubit_type_id \\ nil) do
    {:ok, object } =
      docubit_attrs(type, document_version_id, docubit_type_id)
      |> Documents.create_docubit()
    object
  end

  def docubit_attrs(:p, document_version_id, docubit_type_id) do
    %{
      type_id: "p",
      document_version_id: document_version_id,
      docubit_type_id: docubit_type_id
    }
  end

  def docubit_attrs(:img, document_version_id, docubit_type_id) do
    %{
      type_id: "img",
      document_version_id: document_version_id,
      docubit_type_id: docubit_type_id
    }
  end

  def docubit_attrs(:ol, document_version_id, docubit_type_id) do
    %{
      type_id: "ol",
      document_version_id: document_version_id,
      docubit_type_id: docubit_type_id
    }
  end

  def docubit_attrs(:row, document_version_id, docubit_type_id) do
    %{
      type_id: "row",
      document_version_id: document_version_id,
      docubit_type_id: docubit_type_id
    }
  end

  def docubit_attrs(:column, document_version_id, docubit_type_id) do
    %{
      type_id: "column",
      document_version_id: document_version_id,
      docubit_type_id: docubit_type_id
    }
  end

  def docubit_attrs(:container, document_version_id, docubit_type_id) do
    %{
      type_id: "container",
      document_version_id: document_version_id,
      docubit_type_id: docubit_type_id
    }
  end

  def docubit_type(type) do
    {:ok, object } =
      docubit_type_attrs(type)
      |> Documents.create_docubit_type()
    object
  end

  def docubit_type_attrs(:container), do: DocubitType.container_attrs()
  def docubit_type_attrs(:row), do: DocubitType.row_attrs()
  def docubit_type_attrs(:ol), do: DocubitType.ol_attrs()
  def docubit_type_attrs(:invalid) do
    %{
      name: "",
      context: %{},
      allowed_children: [ 1 ],
      allowed_data: [ 2 ]
    }
  end

  def create_docubit_types() do
    Enum.map(
      DocubitType.attrs(),
      fn(attrs) ->
        { :ok, docubit_type } = Documents.create_docubit_type(attrs)
        docubit_type
      end
    )
  end
end
