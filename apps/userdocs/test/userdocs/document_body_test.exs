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

      columns = [ Map.put(column, :docubits, [ p ]), column, column]

      rows = [ row, Map.put(row, :docubits, columns), row ]

      empty_body = Map.put(document.body, :type, Type.container())

      body =
        document.body
        |> Map.put(:docubits, rows)

      document = Map.put(document, :body, body)

      team = UsersFixtures.team()
      container = DocubitFixtures.container()
      row = row
      column = column

      page = WebFixtures.page()
      badge_annotation_type = WebFixtures.annotation_type(:badge)
      outline_annotation_type = WebFixtures.annotation_type(:outline)

      content_one =
        DocumentFixtures.content(team)

      content_two =
        DocumentFixtures.content(team)

      content_three =
        DocumentFixtures.content(team)

      file_one = MediaFixtures.file()
      file_two = MediaFixtures.file()
      file_three = MediaFixtures.file()
      file_four = MediaFixtures.file()

      annotation_one =
        WebFixtures.annotation(page)
        |> Map.put(:annotation_type_id, badge_annotation_type.id)
        |> Map.put(:annotation_type, badge_annotation_type)

      annotation_two =
        WebFixtures.annotation(page)
        |> Map.put(:annotation_type_id, outline_annotation_type.id)
        |> Map.put(:annotation_type, outline_annotation_type)

      strategy = WebFixtures.strategy()

      element_one =
        WebFixtures.element(page, strategy)
        |> Map.put(:strategy, strategy)

      element_two =
        WebFixtures.element(page, strategy)
        |> Map.put(:strategy, strategy)

      empty_step =
        AutomationFixtures.step()
        |> Map.put(:annotation, nil)
        |> Map.put(:element, nil)

      step_with_annotation =
        AutomationFixtures.step()
        |> Map.put(:annotation_id, annotation_one.id)
        |> Map.put(:annotation, annotation_one)
        |> Map.put(:element, nil)

      step_with_element =
        AutomationFixtures.step()
        |> Map.put(:element_id, element_two.id)
        |> Map.put(:element, element_two)
        |> Map.put(:annotation, nil)

      step_with_both =
        AutomationFixtures.step()
        |> Map.put(:element_id, element_two.id)
        |> Map.put(:element, element_two)
        |> Map.put(:annotation_id, annotation_one.id)
        |> Map.put(:annotation, annotation_one)

      %{
        document: document,
        container: container,
        ol: ol,
        ol_type: ol_type,
        row: row,
        column: column,
        empty_body: empty_body,
        state: %{
          data: %{
            files: [ file_one, file_two, file_three, file_four ],
            content: [ content_one, content_two, content_three ],
            steps: [empty_step, step_with_annotation, step_with_element, step_with_both],
            annotations: [ annotation_one, annotation_two ],
            elements: [ element_one, element_two ],
            strategies: [ strategy ],
            annotation_types: [badge_annotation_type, outline_annotation_type]
          }
        }
      }
    end
"""
    test "document body's children is an empty container" do
      attrs = %{ name: "test", title: "Test" }
      container =
        DocubitFixtures.container()
        |> Map.put(:type, Type.container())

      { :ok, document } = Documents.create_document(attrs)
      assert document.body == container
    end

    test "get ([0]) retreives the body docubit" do
      f = docubit_fixture()
      document = f.document
      assert Docubit.get(document.body, [0]) == document.body
    end

    test "get ([0, 0]) retreives a row docubit" do
      f = docubit_fixture()
      document = f.document
      assert Docubit.get(document.body, [0, 0]) == f.row
    end

    test "get ([0, 1, 1]) retreives a column docubit" do
      f = docubit_fixture()
      document = f.document
      assert Docubit.get(document.body, [0, 1, 1]) == f.column
    end

    test "put ([0]) raises an error" do
      f = docubit_fixture()
      document = f.document
      assert_raise(RuntimeError, "Can't replace the document body directly",
        fn -> Docubit.insert(document.body, [0], f.row) end)
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
      { status, docubit, _errors } = Docubit.insert(body, address, f.row)
      assert status == :ok
      assert Docubit.get(docubit, address) == f.row
    end

    test "insert([0, 1, 1, 1]) puts an ol docubit in a column" do
      f = docubit_fixture()
      document = f.document
      address = [ 0, 1, 1, 0 ]
      { status, docubit, _errors } = Docubit.insert(document.body, address, f.ol)
      assert status == :ok
      assert Docubit.get(docubit, address) == f.ol
    end

    test "update([0, 1, 1]) fails to update an ol docubit in the body because it's not an allowed type" do
      f = docubit_fixture()
      document = f.document
      address = [ 0, 1, 1 ]
      { :error, _updated_body, errors } = Docubit.update(document.body, address, f.ol)
      assert errors == [docubits: {"This type may not be inserted into this docubit.", []}]
    end
"""
    test "update([ 0, 1, 0, 0 ]) updates an ol docubit in the body" do
      f = docubit_fixture()
      document = f.document
      address = [ 0, 1, 0, 0 ]
      { status, updated_body, _errors } = Docubit.update(document.body, address, f.ol)
      assert status == :ok
      assert Docubit.get(updated_body, address) == f.ol
    end

  end
end
