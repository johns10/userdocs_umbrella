defmodule UserDocs.DocumentHydrationTest do
  use UserDocs.DataCase

  describe "document_version_body" do
    alias UserDocs.Documents.Docubit, as: Docubit

    alias UserDocs.DocubitFixtures
    alias UserDocs.WebFixtures
    alias UserDocs.UsersFixtures
    alias UserDocs.AutomationFixtures
    alias UserDocs.DocumentFixtures
    alias UserDocs.MediaFixtures

    alias UserDocs.Documents
    alias UserDocs.Documents.Docubit.Type

    def docubit_fixture() do
      { :ok, document_version } =
        Documents.create_document_version(%{ name: "test", title: "Test" })

      empty_document_version = document_version
      empty_body = document_version.body

      ol_type =
        Type.types()
        |> Enum.filter(fn(t) -> t.id == "ol" end)
        |> Enum.at(0)

      ol =
        DocubitFixtures.ol()
        |> Map.put(:type, Type.p())

      p =
        DocubitFixtures.p()
        |> Map.put(:type, Type.p())

      img =
        DocubitFixtures.img()
        |> Map.put(:type, Type.img())

      row =
        DocubitFixtures.row()
        |> Map.put(:type, Type.row())

      column =
        DocubitFixtures.column()
        |> Map.put(:type, Type.column())

      body =
        document_version.body
        |> Docubit.insert([ 0, 0 ], row)
        |> Docubit.insert([ 0, 1 ], row)
        |> Docubit.insert([ 0, 2 ], row)
        |> Docubit.insert([ 0, 0, 0 ], column)
        |> Docubit.insert([ 0, 0, 1 ], column)
        |> Docubit.insert([ 0, 0, 2 ], column)
        |> Docubit.insert([ 0, 0, 0, 0 ], p)
        |> Docubit.insert([ 0, 0, 1, 0 ], img)

      document_version = Map.put(document_version, :body, body)

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
        |> Map.put(:content_id, content_one.id)
        |> Map.put(:content, content_one)

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

      step_with_screenshot =
        AutomationFixtures.step()

      screenshot =
        MediaFixtures.screenshot(file_one.id, step_with_screenshot.id)
        |> Map.put(:file, file_one)

      step_with_screenshot =
        step_with_screenshot
        |> Map.put(:screenshot, screenshot)

      %{
        document_version: document_version,
        empty_ddocument_version: empty_document_version,
        container: container,
        ol: ol,
        ol_type: ol_type,
        row: row,
        column: column,
        empty_body: empty_body,
        step_with_screenshot: step_with_screenshot,
        state: %{
          data: %{
            files: [ file_one, file_two, file_three, file_four ],
            content: [ content_one, content_two, content_three ],
            steps: [empty_step, step_with_annotation, step_with_element, step_with_both, step_with_screenshot],
            annotations: [ annotation_one, annotation_two ],
            elements: [ element_one, element_two ],
            strategies: [ strategy ],
            annotation_types: [badge_annotation_type, outline_annotation_type]
          }
        }
      }
    end

    test "hydrate adds content and content id on a docubit" do
      f = docubit_fixture()
      document_versions = f.document_versions
      content = Enum.at(f.state.data.content, 0)
      address = [ 0, 0, 0, 0 ]
      updated_body = Docubit.hydrate(document_versions.body, address, content)
      updated_docubit = Docubit.get(updated_body, address)
      assert updated_docubit.content == content
    end

    test "hydrate adds content and through_annotation on a docubit" do
      f = docubit_fixture()
      document_versions = f.document_versions
      annotation = Enum.at(f.state.data.annotations, 0)
      address = [ 0, 0, 0, 0 ]
      updated_body = Docubit.hydrate(document_versions.body, address, annotation)
      updated_docubit = Docubit.get(updated_body, address)
      assert updated_docubit.through_annotation == annotation
      assert updated_docubit.through_annotation_id == annotation.id
      assert updated_docubit.content == annotation.content
      assert updated_docubit.content_id == annotation.content_id
    end

    test "hydrate adds content, through_annotation, and through_step on a p docubit when a step is added" do
      f = docubit_fixture()
      document_versions = f.document_versions
      step = Enum.at(f.state.data.steps, 1)
      address = [ 0, 0, 0, 0 ]
      updated_body = Docubit.hydrate(document_versions.body, address, step)
      updated_docubit = Docubit.get(updated_body, address)
      assert updated_docubit.through_step == step
      assert updated_docubit.through_step_id == step.id
      assert updated_docubit.through_annotation == step.annotation
      assert updated_docubit.through_annotation_id == step.annotation.id
      assert updated_docubit.content == step.annotation.content
      assert updated_docubit.content_id == step.annotation.content_id
    end

    test "hydrate adds file and through_step on a img docubit when a step is added" do
      f = docubit_fixture()
      document_versions = f.document_versions
      step = f.step_with_screenshot
      address = [ 0, 0, 1, 0 ]
      updated_body = Docubit.hydrate(document_versions.body, address, step)
      updated_docubit = Docubit.get(updated_body, address)
      assert updated_docubit.through_step.screenshot == step.screenshot
      assert updated_docubit.through_step.screenshot.file == step.screenshot.file
    end

  end
end
