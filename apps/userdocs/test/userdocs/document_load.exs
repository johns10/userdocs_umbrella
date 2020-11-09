defmodule UserDocs.DocumentLoadTest do
  use UserDocs.DataCase

  alias UserDocs.Documents


  describe "document load" do
    alias UserDocs.Documents.Docubit
    alias UserDocs.Documents.Document
    alias UserDocs.DocubitFixtures
    alias UserDocs.Documents.Docubit.Type

    test "stored document is the same as the retreived document" do
      attrs = %{ name: "test", title: "Test" }
      { :ok, document } = Documents.create_document(attrs)
      retreived_document = Documents.get_document!(document.id)
      # TODO: Remove later.  Shouldn't be necessary.  Should take the preloads out of the changeset
      created = Map.delete(document, :type)
      result = Map.delete(retreived_document, :type)
      assert created == created
    end

    test "creating a document with some body attributes stores and retreives" do
      attrs = %{ name: "test", title: "Test" }
      { :ok, document } = Documents.create_document(attrs)

      row =
        DocubitFixtures.row()
        |> Map.put(:type, Type.row())

      body =
        document.body
        |> Docubit.insert([ 0, 0 ], row)
        |> Docubit.insert([ 0, 1 ], row)
        |> Docubit.insert([ 0, 2 ], row)


      attrs = %{ body: body }

      { :ok, document } = Documents.update_document(document, attrs)
    end

  end
end
