defmodule UserDocs.DocumentBodyTest do
  use UserDocs.DataCase

  describe "document_body" do
    alias UserDocs.Documents.Docubit

    alias UserDocs.DocubitFixtures
    alias UserDocs.WebFixtures
    alias UserDocs.UsersFixtures
    alias UserDocs.AutomationFixtures
    alias UserDocs.DocumentFixtures
    alias UserDocs.MediaFixtures

    alias UserDocs.Documents
    alias UserDocs.Documents.Document
    alias UserDocs.Documents.Docubit.Type

    def empty_document(), do: DocumentFixtures.empty_document

    def document_with_columns_and_rows do
      document = empty_document()
      body = Documents.get_docubit!(document.body.id, %{docubits: true})
      row =
        body
        |> add_rows(document.id)
        |> Map.get(:docubits)
        |> Enum.at(0)

      row =
        Documents.get_docubit!(row.id, %{docubits: true})
        |> add_columns(document.id)

      Documents.get_document!(document.id, %{ docubits: true })
    end

    def add_rows(docubit, document_id) do
      attrs = %{ docubits: [
        DocubitFixtures.docubit_attrs(:row, document_id),
        DocubitFixtures.docubit_attrs(:row, document_id),
        DocubitFixtures.docubit_attrs(:row, document_id),
      ] }
      { :ok, docubit } = Documents.update_docubit(docubit, attrs)
      docubit
    end

    def add_columns(docubit, document_id) do
      attrs = %{ docubits: [
        DocubitFixtures.docubit_attrs(:column, document_id),
        DocubitFixtures.docubit_attrs(:column, document_id),
        DocubitFixtures.docubit_attrs(:column, document_id),
      ]}
      { :ok, docubit } = Documents.update_docubit(docubit, attrs)
      docubit
    end

    def document_fixture() do
      empty_document = empty_document()
      document = empty_document()
      body =
        Documents.get_docubit!(document.body.id, %{docubits: true})
        |> add_rows(document.id)

      body =
        Documents.get_docubit!(body.id, %{docubits: true})

      %{
        empty_document: empty_document,
        document: Map.put(document, :body, body)
      }
    end

    test "new docubit gets a container docubit by default" do
      document_attrs = %{ name: "test", title: "Test" }
      { :ok, document } = Documents.create_document(document_attrs)
      assert document.body.type_id == "container"
    end

    test "adding a couple rows to a docubit works" do
      document = empty_document()
      body = Documents.get_docubit!(document.body.id, %{docubits: true})
      row =
        body
        |> add_rows(document.id)
        |> Map.get(:docubits)
        |> Enum.at(0)

      row.type_id == "row"
    end

    test "adding columns to rows works" do
      document = empty_document()
      body = Documents.get_docubit!(document.body.id, %{docubits: true})
      row =
        body
        |> add_rows(document.id)
        |> Map.get(:docubits)
        |> Enum.at(0)

      row =
        Documents.get_docubit!(row.id, %{docubits: true})
        |> add_columns(document.id)

      column = Enum.at(row.docubits, 0)
      column.type_id == "column"
    end

    test "adding a column to body raises an error" do
      document = empty_document()
      body = document.body
      body = Documents.get_docubit!(body.id, %{docubits: true})
      attrs = %{
        document_id: document.id,
        docubits: [ DocubitFixtures.docubit_attrs(:column, document.id) ]
      }
      { status, row } = Documents.update_docubit(body, attrs)
      assert status == :error
      { error, [] } = row.errors[:docubits]
      assert error == "This type may not be inserted into this docubit."
    end

    test "adding fetching a document with columns and rows includes the docubits" do
      document = document_with_columns_and_rows()
      assert Enum.count(document.docubits) == 7
    end

    test "map_docubits maps the docubits" do
      document = document_with_columns_and_rows()
      docubit_map = Document.map_docubits(document)
      IO.inspect(docubit_map)
      assert docubit_map[0].id == document.docubit_id
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
