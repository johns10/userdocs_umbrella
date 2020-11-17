defmodule UserDocs.DocumentVersionBodyTest do
  use UserDocs.DataCase

  describe "document_version_body" do
    alias UserDocs.Documents.Docubit

    alias UserDocs.DocubitFixtures
    alias UserDocs.WebFixtures
    alias UserDocs.UsersFixtures
    alias UserDocs.AutomationFixtures
    alias UserDocs.DocumentFixtures
    alias UserDocs.MediaFixtures

    alias UserDocs.Documents
    alias UserDocs.Documents.DocumentVersion
    alias UserDocs.Documents.Docubit.Type

    def empty_document_version(), do: DocumentVersionFixtures.empty_document_version

    def document_version_with_columns_and_rows do
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

      Documents.get_document_version!(document_version.id, %{ docubits: true })
    end

    def add_rows(docubit, document_version_id) do
      attrs = %{ docubits: [
        DocubitFixtures.docubit_attrs(:row, document_version_id),
        DocubitFixtures.docubit_attrs(:row, document_version_id),
        DocubitFixtures.docubit_attrs(:row, document_version_id),
      ] }
      { :ok, docubit } = Documents.update_docubit(docubit, attrs)
      docubit
    end

    def add_columns(docubit, document_version_id) do
      attrs = %{ docubits: [
        DocubitFixtures.docubit_attrs(:column, document_version_id),
        DocubitFixtures.docubit_attrs(:column, document_version_id),
        DocubitFixtures.docubit_attrs(:column, document_version_id),
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

    test "new docubit gets a container docubit by default" do
      document_version_attrs = %{ name: "test", title: "Test" }
      { :ok, document_version } = Documents.create_document_version(document_version_attrs)
      assert document_version.body.type_id == "container"
    end

    test "adding a couple rows to a docubit works" do
      document_version = empty_document_version()
      body = Documents.get_docubit!(document_version.body.id, %{docubits: true})
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

    test "map_docubits maps the docubits" do
      document_version = document_version_with_columns_and_rows()
      docubit_map = DocumentVersion.map_docubits(document_version)
      IO.inspect(docubit_map)
      assert docubit_map[0].id == document_version.docubit_id
      Enum.each(docubit_map[0][0], fn({ k, v }) ->
        case is_integer(k) do
          true ->
            docubit = Documents.get_docubit!(Map.get(v, :id))
            assert docubit.type_id == "column"
          false -> ""
        end
      end)
    end
  end
end
