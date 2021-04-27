defmodule UserDocs.DocumentVersionBodyTest do
  use UserDocs.DataCase

  describe "document_version_body" do

    alias UserDocs.DocubitFixtures
    alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures
    alias UserDocs.StateFixtures

    alias UserDocs.Documents

    def empty_document_version(), do: DocumentFixtures.empty_document_version

    def state_opts() do
      [ data_type: :list, strategy: :by_type, location: :data ]
    end

    def document_fixture() do
      opts = state_opts()
      %{}
      |> StateFixtures.base_state(opts)
      |> DocubitFixtures.docubit_types(opts)
      |> DocumentFixtures.state(opts)
    end

    test "new docubit gets a container docubit by default" do
      DocubitFixtures.create_docubit_types()
      document_version_attrs = DocumentFixtures.document_version_attrs(:valid)
      { :ok, document_version } = Documents.create_document_version(document_version_attrs)
      type = Documents.get_docubit_type!(document_version.body.docubit_type_id)
      assert document_version.body.document_version_id == document_version.id
      assert type.name == "container"
    end

    def document_version_with_one_row do
      document_version = empty_document_version()
      body = Documents.get_docubit!(document_version.body.id, %{docubits: true})

      body
      |> add_row(document_version.id)
      |> Map.get(:docubits)
      |> Enum.at(0)

      Documents.get_document_version!(document_version.id, %{ docubits: true })
    end

    def document_version_with_one_column_and_one_row do
      document_version = empty_document_version()
      body = Documents.get_docubit!(document_version.body.id, %{docubits: true})
      row =
        body
        |> add_row(document_version.id)
        |> Map.get(:docubits)
        |> Enum.at(0)

      Documents.get_docubit!(row.id, %{docubits: true})
      |> add_column(document_version.id)

      Documents.get_document_version!(document_version.id, %{ docubits: true })
    end

    def document_version_with_columns_and_rows do
      document_version = empty_document_version()
      body = Documents.get_docubit!(document_version.body.id, %{docubits: true})
      row =
        body
        |> add_rows(document_version.id)
        |> Map.get(:docubits)
        |> Enum.at(0)

      Documents.get_docubit!(row.id, %{docubits: true})
      |> add_columns(document_version.id)

      Documents.get_document_version!(document_version.id, %{ docubits: true })
    end

    def document_version_with_rows do
      document_version = empty_document_version()
      body = Documents.get_docubit!(document_version.body.id, %{docubits: true})

      body
      |> add_rows(document_version.id)
      |> Map.get(:docubits)
      |> Enum.at(0)

      Documents.get_document_version!(document_version.id, %{ docubits: true })
    end

    def add_row(docubit, document_version_id) do
      docubit_type = Documents.get_docubit_type!("row")
      attrs = %{ docubits: [
        DocubitFixtures.docubit_attrs(:row, document_version_id, docubit_type.id)
      ] }
      { :ok, docubit } = Documents.update_docubit(docubit, attrs)
      docubit
    end

    def add_rows(docubit, document_version_id) do
      docubit_type = Documents.get_docubit_type!("row")
      attrs = %{ docubits: [
        DocubitFixtures.docubit_attrs(:row, document_version_id, docubit_type.id),
        DocubitFixtures.docubit_attrs(:row, document_version_id, docubit_type.id),
        DocubitFixtures.docubit_attrs(:row, document_version_id, docubit_type.id),
      ] }
      { :ok, docubit } = Documents.update_docubit(docubit, attrs)
      docubit
    end

    def add_column(docubit, document_version_id) do
      docubit_type = Documents.get_docubit_type!("column")
      attrs = %{ docubits: [
        DocubitFixtures.docubit_attrs(:column, document_version_id, docubit_type.id)
      ]}
      { :ok, docubit } = Documents.update_docubit(docubit, attrs)
      docubit
    end

    def add_columns(docubit, document_version_id) do
      docubit_type = Documents.get_docubit_type!("column")
      attrs = %{ docubits: [
        DocubitFixtures.docubit_attrs(:column, document_version_id, docubit_type.id),
        DocubitFixtures.docubit_attrs(:column, document_version_id, docubit_type.id),
        DocubitFixtures.docubit_attrs(:column, document_version_id, docubit_type.id),
      ]}
      { :ok, docubit } = Documents.update_docubit(docubit, attrs)
      docubit
    end

    def document_version_fixture() do
      empty_document_version = empty_document_version()
      document_version = empty_document_version()
      body =
        Documents.get_docubit!(document_version.body.id, %{docubits: true})
        |> add_rows(document_version.id)

      body =
        Documents.get_docubit!(body.id, %{docubits: true})

      %{
        empty_document_version: empty_document_version,
        document_version: Map.put(document_version, :body, body)
      }
    end
    """
    test "adding a couple rows to a docubit works" do
      state = document_fixture()
      document_version = Documents.list_document_versions(state, state_opts()) |> Enum.at(0)
      body = Documents.get_docubit!(document_version.docubit_id, %{docubits: true})
      row =
        body
        |> add_rows(document_version.id)
        |> Map.get(:docubits)
        |> Enum.at(0)

      row.type_id == "row"
    end

    test "adding columns to rows works" do
      document_version = empty_document_version()
      body = Documents.get_docubit!(document_version.body.id, %{docubits: true})
      row =
        body
        |> add_rows(document_version.id)
        |> Map.get(:docubits)
        |> Enum.at(0)

      row =
        Documents.get_docubit!(row.id, %{docubits: true})
        |> add_columns(document_version.id)

      column = Enum.at(row.docubits, 0)
      column.type_id == "column"
    end

    test "adding a column to body raises an error" do
      document_version = empty_document_version()
      body = document_version.body
      body = Documents.get_docubit!(body.id, %{docubits: true})
      attrs = %{
        document_version_id: document_version.id,
        docubits: [ DocubitFixtures.docubit_attrs(:column, document_version.id) ]
      }
      { status, row } = Documents.update_docubit(body, attrs)
      assert status == :error
      { error, [] } = row.errors[:docubits]
      assert error == "This type may not be inserted into this docubit."
    end

    test "adding fetching a document_version with columns and rows includes the docubits" do
      document_version = document_version_with_columns_and_rows()
      assert Enum.count(document_version.docubits) == 7
    end

    test "map_docubits base case" do
      document_version_attrs = DocumentVersionFixtures.document_version_attrs(:valid)
      { :ok, document_version } = Documents.create_document_version(document_version_attrs)
      document_version = Documents.get_document_version!(document_version.id, %{docubits: true})
      docubit_map = DocumentVersion.map_docubits(document_version)
      assert docubit_map[0].docubit.id == document_version.docubit_id
    end

    test "map_docubits single row" do
      document_version = document_version_with_one_row()
      document_version = Documents.get_document_version!(document_version.id, %{docubits: true})
      docubit_map = DocumentVersion.map_docubits(document_version)
      row = document_version.docubits |> Enum.at(1)
      assert row.type_id == "row"
      assert docubit_map[0].docubit.id == document_version.docubit_id
      assert docubit_map[0].docubit.docubits[0].docubit.id == row.id
    end

    test "map_docubits single row, single column" do
      document_version = document_version_with_one_column_and_one_row()
      docubit_map = DocumentVersion.map_docubits(document_version)
      row = document_version.docubits |> Enum.at(1)
      column = document_version.docubits |> Enum.at(2)
      assert docubit_map[0].docubit.id == document_version.docubit_id
      assert docubit_map[0].docubit.docubits[0].docubit.docubits[0].docubit.id == column.id
    end

    test "map_docubits maps the docubits" do
      document_version = document_version_with_one_column_and_one_row()
      docubit_map = DocumentVersion.map_docubits(document_version)
      assert docubit_map[0].docubit.id == document_version.docubit_id
      Enum.each(docubit_map[0].docubit.docubits[0], fn({ k, v }) ->
        case is_integer(k) do
          true ->
            docubit = Documents.get_docubit!(Map.get(v, :id))
            assert docubit.type_id == "column"
          false -> ""
        end
      end)
    end

    test "traverse_document_body bodies the docubits" do
      # TODO: Fixt this.  use the loader
      document_version = document_version_with_columns_and_rows()
      state = Map.put(DocubitFixtures.state(), :docubits, document_version.docubits)
      state = Map.put(%{}, :data, state)
      document_version = DocumentVersion.load(document_version, state, state_opts)
      row = Enum.at(document_version.body.docubits, 0)
      column = Enum.at(row.docubits, 0)
      assert row.type_id == "row"
      assert column.type_id == "column"
    end
    """
  end
end
