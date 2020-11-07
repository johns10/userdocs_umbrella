defmodule UserDocs.DocumentBodyTest do
  use UserDocs.DataCase

  describe "document_body" do
    alias UserDocs.Documents.NewDocubit, as: Docubit

    alias UserDocs.DocubitFixtures
    alias UserDocs.WebFixtures
    alias UserDocs.UsersFixtures
    alias UserDocs.AutomationFixtures
    alias UserDocs.DocumentFixtures
    alias UserDocs.MediaFixtures

    alias UserDocs.Documents
    alias UserDocs.Documents.Docubit.Type

    def docubit_fixture() do
      { :ok, document } =
        Documents.create_document(%{ name: "test", title: "Test" })

      empty_document = document
      empty_body = document.body

      ol_type =
        Type.types()
        |> Enum.filter(fn(t) -> t.id == "ol" end)
        |> Enum.at(0)

      ol = DocubitFixtures.ol()
      p = DocubitFixtures.p()
      row =
        DocubitFixtures.row()
        |> Map.put(:type, Type.row())

      column =
        DocubitFixtures.column()
        |> Map.put(:type, Type.column())

      body =
        document.body
        |> Docubit.insert([ 0, 0 ], row)
        |> Docubit.insert([ 0, 1 ], row)
        |> Docubit.insert([ 0, 2 ], row)
        |> Docubit.insert([ 0, 0, 0 ], column)
        |> Docubit.insert([ 0, 0, 1 ], column)
        |> Docubit.insert([ 0, 0, 2 ], column)
        |> Docubit.insert([ 0, 0, 0, 0 ], p)

      document = Map.put(document, :body, body)

      team = UsersFixtures.team()
      container = DocubitFixtures.container()
      row = row
      column = column

      %{
        document: document,
        empty_document: empty_document,
        container: container,
        ol: ol,
        ol_type: ol_type,
        row: row,
        column: column,
        empty_body: empty_body
      }
    end

    test "document body's children is an empty container" do
      attrs = %{ name: "test", title: "Test" }
      container =
        DocubitFixtures.container()
        |> Map.put(:type, Type.container())

      { :ok, document } = Documents.create_document(attrs)
      assert document.body == container
    end

    test "put ([0]) raises an error" do
      f = docubit_fixture()
      document = f.document
      assert_raise(RuntimeError, "Can't replace the document body directly",
        fn -> Docubit.insert(document.body, [0], f.row) end)
    end

    test "update([0, 1, 1]) fails to update an ol docubit in the body because it's not an allowed type" do
      f = docubit_fixture()
      document = f.document
      address = [ 0, 1, 1 ]
      { :error, _updated_body, errors } = Docubit.update(document.body, address, f.ol)
      assert errors == [docubits: {"This type may not be inserted into this docubit.", []}]
    end

    test "update([ 0, 0, 0, 0 ]) updates an ol docubit in the body" do
      f = docubit_fixture()
      document = f.document
      address = [ 0, 0, 0, 0 ]
      updated_body = Docubit.update(document.body, address, f.ol)
      assert Docubit.get(updated_body, address) == Map.put(f.ol, :address, address)
    end

    test "delete([ 0, 1, 0, 0 ]) fails to delete an ol docubit from the body" do
      f = docubit_fixture()
      document = f.document
      address = [ 0, 1, 0, 0 ]
      { status, updated_body, _errors } = Docubit.delete(document.body, address, f.ol)
      assert status == :error
    end

    test "delete([ 0, 0, 0, 0 ]) deletes an ol docubit from the body" do
      f = docubit_fixture()
      document = f.document
      address = [ 0, 0, 0, 0 ]
      updated_body = Docubit.delete(document.body, address, f.ol)
      { status, _updated_body, _errors } = Docubit.get(updated_body, address)
      assert status == :error
    end

    test "get ([0]) retreives the body docubit" do
      f = docubit_fixture()
      document = f.document
      address = [0]
      updated_body = Docubit.get(document.body, address)
      assert updated_body == document.body
    end

    test "get ([0, 0]) retreives a row docubit" do
      f = docubit_fixture()
      document = f.document
      address = [0, 0]
      updated_body = Docubit.get(document.body, address)
      assert Map.put(updated_body, :docubits, []) == Map.put(f.row, :address, address)
    end

    test "get ([0, 0, 1]) retreives a column docubit" do
      f = docubit_fixture()
      document = f.document
      address = [0, 0, 1]
      updated_body = Docubit.get(document.body, address)
      assert updated_body == Map.put(f.column, :address, address)
    end

    test "get ([0, 1, 99]) returns an error" do
      f = docubit_fixture()
      document = f.document
      address = [0, 1, 99]
      { status, _updated_body, _errors } = Docubit.get(document.body, address)
      assert status == :error
    end

    test "insert([0,0]) tries to put a column in a body and raises an error" do
      f = docubit_fixture()
      body = f.empty_body
      address = [ 0, 0 ]
      { :error, _changeset, error } = Docubit.insert(body, address, f.column)
      assert error == [docubits: {"This type may not be inserted into this docubit.", []}]
    end

    test "insert([0,0]) puts a row in an empty body" do
      f = docubit_fixture()
      body = f.empty_body
      address = [ 0, 0 ]
      updated_body = Docubit.insert(body, address, f.row)
      result_body = Docubit.get(updated_body, address)
      assert result_body == Map.put(f.row, :address, address)
    end

    test "insert([0, 1, 1, 1]) puts an ol docubit in a column" do
      f = docubit_fixture()
      document = f.document
      address = [0, 0, 0, 0 ]
      docubit = Docubit.insert(document.body, address, f.ol)
      assert Docubit.get(docubit, address) == Map.put(f.ol, :address, address)
    end

  end
end
