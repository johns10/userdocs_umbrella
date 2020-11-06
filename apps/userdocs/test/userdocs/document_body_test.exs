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
    alias UserDocs.Documents.Body
    alias UserDocs.Documents.Docubit.Type

    def docubit_fixture() do
      { :ok, document } =
        Documents.create_document(%{ name: "test", title: "Test" })

      columns = [
        DocubitFixtures.column(),
        DocubitFixtures.column(),
        DocubitFixtures.column()
      ]

      rows = [
        DocubitFixtures.row(),
        Map.put(DocubitFixtures.row(), :docubits, columns),
        DocubitFixtures.row()
      ]

      body =
        document.body
        |> Map.put(:docubits, rows)

      document = Map.put(document, :body, body)

      team = UsersFixtures.team()
      container = DocubitFixtures.container()
      row = DocubitFixtures.row()
      column = DocubitFixtures.column()
      ol = DocubitFixtures.ol()

      ol_type =
        Type.types()
        |> Enum.filter(fn(t) -> t.id == "ol" end)
        |> Enum.at(0)

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
    """
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

    test "get ([0, 1, 0]) retreives a column docubit" do
      f = docubit_fixture()
      document = f.document
      assert Docubit.get(document.body, [0, 1, 0]) == f.column
    end

    test "insert([0, 1, 1]) puts an ol docubit in the body" do
      f = docubit_fixture()
      document = f.document
      body = Docubit.insert(document.body, [ 0, 1, 1 ], f.ol)
      IO.puts(Docubit.print(body))
      assert Docubit.get(body, [ 0, 1, 1 ]) == f.ol
    end
  end
end
