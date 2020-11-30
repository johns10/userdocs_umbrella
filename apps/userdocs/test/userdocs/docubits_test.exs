defmodule UserDocs.DocubitsTest do
  use UserDocs.DataCase

  describe "docubits" do
    alias UserDocs.Documents
    alias UserDocs.Documents.Docubit, as: Docubit
    alias UserDocs.Documents.Docubit.Context


    alias UserDocs.DocubitFixtures

    alias UserDocs.Documents.Docubit.Type

    def docubit_fixture() do
      DocubitFixtures.state()
    end

    def state_opts() do
      [ data_type: :list, strategy: :by_type, location: :data ]
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
      docubit = StateHandlers.preload(f.state, docubit, [ :content ], state_opts())
      assert docubit.content == content
    end

    test "Docubit.preload preloads a file" do
      f = docubit_fixture()
      ol = f.ol
      file = Enum.at(f.state.data.files, 0)
      docubit = Map.put(ol, :file_id, file.id)
      docubit = StateHandlers.preload(f.state, docubit, [ :file ], state_opts())
      assert docubit.file == file
    end

    test "Docubit.preload preloads an annotation" do
      f = docubit_fixture()
      ol = f.ol
      annotation = Enum.at(f.state.data.annotations, 0)
      docubit = Map.put(ol, :through_annotation_id, annotation.id)
      docubit = StateHandlers.preload(f.state, docubit, [ :through_annotation ], state_opts())
      assert docubit.through_annotation == annotation
    end

    test "Docubit.fetch_renderer fetches the correct renderer" do
      f = docubit_fixture()
      docubit =
        f.row
        |> Docubit.apply_contexts(%{})
        |> Docubit.renderer()

      assert docubit.renderer == :"Elixir.UserDocs.Documents.Docubit.Renderers.Row"
    end

    test "context gets the parent context and overwrites a nil settings context" do
      f = docubit_fixture()
      ol = f.ol
      ol_type = f.ol_type
      context = %Context{ settings: [ li_value: "test_value"] }
      { :ok, context } = Docubit.context(ol, context)
      assert context.settings[:li_value] == "test_value"
    end

    test "update_context changes a context" do
      context = %Context{}
      context_changes = %{ settings: [ li_value: "test_value"] }
      { :ok, context } = Context.update_context(context, context_changes)
      assert context.settings[:li_value] == "test_value"
    end

    test "context applies context correctly" do
      f = docubit_fixture()
      ol = f.ol
      context = %Context{ settings: [ li_value: "test_value"] }
      { :ok, context } = Docubit.context(ol, context)
      context.settings[:li_value] == "test_value"
      context.settings[:name_prefix] == False
    end

    test "context respects the heirarchy of parent over type" do
      f = docubit_fixture()
      ol = f.ol
      context = %Context{ settings: [ name_prefix: True] }
      { :ok, context } = Docubit.context(ol, context)
      assert context.settings[:name_prefix] == context.settings[:name_prefix]
    end

    test "context respects the heirarchy of object over parent" do
      f = docubit_fixture()
      ol = f.ol
      attrs = %{ settings: [ name_prefix: True] }
      contexts = %Context{ settings: [ name_prefix: False] }
      changeset = Docubit.changeset(ol, attrs)
      { :ok, docubit } = Ecto.Changeset.apply_action(changeset, :update)
      { :ok, context } = Docubit.context(docubit, contexts)
      assert context.settings[:name_prefix] == attrs.settings[:name_prefix]
    end
  end
end
