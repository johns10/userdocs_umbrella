defmodule UserDocs.DocumentVersionLoadTest do
  use UserDocs.DataCase

  alias UserDocs.Documents


  describe "document_version load" do

    alias UserDocs.DocumentVersionFixtures
    alias UserDocs.UsersFixtures
    alias UserDocs.MediaFixtures
    alias UserDocs.WebFixtures
    alias UserDocs.AutomationFixtures

    alias UserDocs.Documents
    alias UserDocs.Documents.Docubit
    alias UserDocs.Documents.DocumentVersion
    alias UserDocs.DocubitFixtures

    def empty_document_version(), do: DocumentVersionFixtures.empty_document_version

    def document_version_with_one_row() do
      document_version = empty_document_version()
    end

    def state() do
      team = UsersFixtures.team()
      content_one =  DocumentVersionFixtures.content(team.id)
      content_two = DocumentVersionFixtures.content(team.id)
      content_three = DocumentVersionFixtures.content(team.id)
      file_one = MediaFixtures.file()
      file_two = MediaFixtures.file()
      file_three = MediaFixtures.file()
      file_four = MediaFixtures.file()
      badge_annotation_type = WebFixtures.annotation_type(:badge)
      outline_annotation_type = WebFixtures.annotation_type(:outline)
      page = WebFixtures.page()

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
        content_one: content_one,
        data: %{
          files: [file_one, file_two, file_three, file_four],
          content: [content_one, content_two, content_three],
          steps: [empty_step, step_with_annotation, step_with_element, step_with_both],
          annotations: [annotation_one, annotation_two],
          elements: [element_one, element_two],
          strategies: [strategy],
          annotation_types: [badge_annotation_type, outline_annotation_type]
        }
      }
    end

    test "stored document_version is the same as the retreived document_version" do
      attrs = %{name: "test", title: "Test"}
      {:ok, document_version} = Documents.create_document_version(attrs)
      retreived_document_version = Documents.get_document_version!(document_version.id)
      # TODO: Remove later.  Shouldn't be necessary.  Should take the preloads out of the changeset
      created = Map.delete(document_version, :body)
      result = Map.delete(retreived_document_version, :body)
      assert created == result
    end

    test "loading the document_version does the things" do
      state = state()
      document_version = empty_document_version()
      body = document_version.body
      body = Documents.get_docubit!(body.id, %{docubits: true} )
      attrs = %{docubits: [
        DocubitFixtures.docubit_attrs(:row, document_version.id)
        |> Map.put(:content_id, state.content_one.id)
      ]}
      {:ok, body} = Documents.update_docubit(body, attrs)

      document_version = Documents.get_document_version!(document_version.id, %{docubits: true})
      object = DocumentVersion.load(document_version, state)
    end

  end
end
