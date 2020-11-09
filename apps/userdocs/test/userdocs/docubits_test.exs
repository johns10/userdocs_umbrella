defmodule UserDocs.DocubitsTest do
  use UserDocs.DataCase

  describe "docubits" do
    alias UserDocs.Documents.Docubit, as: Docubit

    alias UserDocs.DocubitFixtures
    alias UserDocs.WebFixtures
    alias UserDocs.UsersFixtures
    alias UserDocs.AutomationFixtures
    alias UserDocs.DocumentFixtures
    alias UserDocs.MediaFixtures

    alias UserDocs.Documents.Docubit.Type

    def docubit_fixture() do
      team = UsersFixtures.team()
      row = DocubitFixtures.row()
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
        ol: ol,
        ol_type: ol_type,
        row: row,
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

    test "apply_context applies a context to the docubit" do
      f = docubit_fixture()
      ol = f.ol
      ol_type = f.ol_type
      contexts = %{ settings: [ li_value: "test_value"] }
      docubit = Docubit.apply_contexts(ol, contexts)
      assert docubit.settings[:li_value] == "test_value"
      assert docubit.settings[:name_prefix] == ol_type.contexts.settings[:name_prefix]
    end

    test "apply_context respects the heirarchy of parent over type" do
      f = docubit_fixture()
      ol = f.ol
      contexts = %{ settings: [ name_prefix: True] }
      docubit = Docubit.apply_contexts(ol, contexts)
      assert docubit.settings[:name_prefix] == contexts.settings[:name_prefix]
    end

    test "apply_context respects the heirarchy of object over parent" do
      f = docubit_fixture()
      ol = f.ol
      attrs = %{ settings: [ name_prefix: True] }
      contexts = %{ settings: [ name_prefix: False] }
      changeset = Docubit.changeset(ol, attrs)
      { :ok, docubit } = Ecto.Changeset.apply_action(changeset, :updateq)
      docubit = Docubit.apply_contexts(docubit, contexts)
      assert docubit.settings[:name_prefix] == attrs.settings[:name_prefix]
    end

    alias UserDocs.Documents.Content

    test "Docubit.preload preloads a content" do
      f = docubit_fixture()
      ol = f.ol
      content = Enum.at(f.state.data.content, 0)
      docubit = Map.put(ol, :content_id, content.id)
      docubit = Docubit.preload(docubit, f.state)
      assert docubit.content == content
    end

    test "Docubit.preload preloads a file" do
      f = docubit_fixture()
      ol = f.ol
      file = Enum.at(f.state.data.files, 0)
      docubit = Map.put(ol, :file_id, file.id)
      docubit = Docubit.preload(docubit, f.state)
      assert docubit.file == file
    end

    test "Docubit.preload preloads an annotation" do
      f = docubit_fixture()
      ol = f.ol
      annotation = Enum.at(f.state.data.annotations, 0)
      docubit = Map.put(ol, :through_annotation_id, annotation.id)
      docubit = Docubit.preload(docubit, f.state)
      assert docubit.through_annotation == annotation
    end

    test "Docubit.fetch_renderer fetches the correct renderer" do
      f = docubit_fixture()
      docubit =
        f.row
        |> Docubit.apply_contexts(%{})
        |> Docubit.renderer()

      assert docubit.renderer == :"Elixir.UserDocs.Documents.OldDocuBit.Renderers.Row"
    end
  end
end
