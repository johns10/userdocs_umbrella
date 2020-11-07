defmodule UserDocs.DocumentHydrationTest do
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
        empty_document: empty_document,
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

    test "hydrate sets the ids and datas on a docubit" do

    end

  end
end
