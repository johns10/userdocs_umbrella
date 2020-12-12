defmodule UserDocs.DocubitsTest do
  use UserDocs.DataCase

  describe "docubits" do
    alias UserDocs.Web
    alias UserDocs.Documents
    alias UserDocs.Media
    alias UserDocs.Documents.Docubit, as: Docubit
    alias UserDocs.Documents.Docubit.Context

    alias UserDocs.DocubitFixtures
    alias UserDocs.WebFixtures
    alias UserDocs.UsersFixtures
    alias UserDocs.AutomationFixtures
    alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures
    alias UserDocs.MediaFixtures
    alias UserDocs.StateFixtures

    def state_opts() do
      [ data_type: :list, strategy: :by_type, location: :data ]
    end

    def docubit_fixture() do
      opts = state_opts()
      %{}
      |> StateFixtures.base_state(opts)
      |> DocubitFixtures.docubit_types(opts)
      |> DocumentFixtures.state(opts)
      |> WebFixtures.state(opts)
      |> MediaFixtures.add_file_to_state(opts)
      |> AutomationFixtures.state(opts)
      |> MediaFixtures.add_screenshot_to_state(opts)
      |> DocubitFixtures.state(opts)
    end

    test "apply_context applies a context to the docubit" do
      opts = Keyword.put(state_opts(), :preloads, [ :docubit_type ])
      state = docubit_fixture()
      docubit = Documents.list_docubits(state, opts) |> Enum.at(0)
      contexts = %{ settings:  %{li_value: "test_value"} }
      updated_docubit = Docubit.apply_contexts(docubit, contexts)
      assert updated_docubit.settings[:li_value] == "test_value"
    end

    test "apply_context respects the heirarchy of parent over type" do
      state = docubit_fixture()
      ol = DocubitFixtures.docubit(:ol, state, state_opts())
      preloaded_ol = Documents.get_docubit!(ol.id, %{ docubit_type: true })
      contexts = %{ settings: %{name_prefix: True} }
      docubit = Docubit.apply_contexts(preloaded_ol, contexts)
      assert docubit.settings[:name_prefix] == contexts.settings[:name_prefix]
    end

    test "apply_context respects the heirarchy of object over parent" do
      state = docubit_fixture()
      ol = DocubitFixtures.docubit(:ol, state, state_opts())
      preloaded_ol = Documents.get_docubit!(ol.id, %{ docubit_type: true })
      attrs = %{ settings:  %{name_prefix: True} }
      contexts = %{ settings: %{name_prefix: False} }
      changeset = Docubit.changeset(preloaded_ol, attrs)
      { :ok, docubit } = Ecto.Changeset.apply_action(changeset, :update)
      docubit = Docubit.apply_contexts(docubit, contexts)
      assert docubit.settings[:name_prefix] == attrs.settings[:name_prefix]
    end

    alias UserDocs.Documents.Content

    test "Docubit.preload preloads a content" do
      opts = Keyword.put(state_opts(), :preloads, [ :content, :docubit_type ])
      state = docubit_fixture()
      ol = DocubitFixtures.docubit(:ol, state, state_opts())
      content = Documents.list_content(state, state_opts()) |> Enum.at(0)
      docubit = Map.put(ol, :content_id, content.id)
      preloaded_docubit = StateHandlers.preload(state, [ docubit ], opts) |> Enum.at(0)
      assert preloaded_docubit.content == content
    end

    test "Docubit.preload preloads a file" do
      opts = Keyword.put(state_opts(), :preloads, [ :file, :docubit_type ])
      state = docubit_fixture()
      ol = DocubitFixtures.docubit(:ol, state, state_opts())
      file = Media.list_files(state, state_opts()) |> Enum.at(0)
      docubit = Map.put(ol, :file_id, file.id)
      preloaded_docubit = StateHandlers.preload(state, [ docubit ], opts) |> Enum.at(0)
      assert preloaded_docubit.file == file
    end

    test "Docubit.preload preloads an annotation" do
      opts = Keyword.put(state_opts(), :preloads, [ :through_annotation, :docubit_type ])
      state = docubit_fixture()
      ol = DocubitFixtures.docubit(:ol, state, state_opts())
      annotation = Web.list_annotations(state, state_opts()) |> Enum.at(0)
      docubit = Map.put(ol, :through_annotation_id, annotation.id)
      preloaded_docubit = StateHandlers.preload(state, [ docubit ], opts) |> Enum.at(0)
      assert preloaded_docubit.through_annotation == annotation
    end

    test "Docubit.fetch_renderer fetches the correct renderer" do
      opts = Keyword.put(state_opts(), :preloads, [ :docubit_type ])
      state = docubit_fixture()
      docubit = DocubitFixtures.docubit(:row, state, state_opts())
      preloaded_docubit = StateHandlers.preload(state, [ docubit ], opts) |> Enum.at(0)
      renderer =
        preloaded_docubit
        |> Docubit.apply_contexts(%{})
        |> Docubit.renderer()

      assert renderer == :"Elixir.UserDocsWeb.DocubitLive.Renderers.Row"
    end

    test "context gets the parent context and overwrites a nil settings context" do
      opts = Keyword.put(state_opts(), :preloads, [ :docubit_type ])
      state = docubit_fixture()
      docubit = DocubitFixtures.docubit(:ol, state, state_opts())
      preloaded_docubit = Documents.get_docubit!(docubit.id, %{ docubit_type: true })
      context = %Context{ settings: [ li_value: "test_value"] }
      { :ok, context } = Docubit.context(preloaded_docubit, context)
      assert context.settings[:li_value] == "test_value"
    end

    test "update_context changes a context" do
      context = %Context{}
      context_changes = %{ settings:  %{li_value: "test_value"} }
      { :ok, context } = Context.update_context(context, context_changes)
      assert context.settings[:li_value] == "test_value"
    end

    test "context applies context correctly" do
      state = docubit_fixture()
      docubit = DocubitFixtures.docubit(:ol, state, state_opts())
      preloaded_docubit = Documents.get_docubit!(docubit.id, %{ docubit_type: true })
      context = %Context{ settings:  %{li_value: "test_value"} }
      { :ok, context } = Docubit.context(preloaded_docubit, context)
      context.settings[:li_value] == "test_value"
      context.settings[:name_prefix] == False
    end

    test "context respects the heirarchy of parent over type" do
      state = docubit_fixture()
      docubit = DocubitFixtures.docubit(:ol, state, state_opts())
      preloaded_docubit = Documents.get_docubit!(docubit.id, %{ docubit_type: true })
      context = %Context{ settings:  %{name_prefix: True} }
      { :ok, context } = Docubit.context(preloaded_docubit, context)
      assert context.settings[:name_prefix] == context.settings[:name_prefix]
    end

    test "context respects the heirarchy of object over parent" do
      state = docubit_fixture()
      docubit = DocubitFixtures.docubit(:ol, state, state_opts())
      docubit = Documents.get_docubit!(docubit.id, %{ docubit_type: true })
      attrs = %{ settings: %{name_prefix: True}}
      contexts = %Context{ settings: %{name_prefix: False}}
      changeset = Docubit.changeset(docubit, attrs)
      { :ok, docubit } = Ecto.Changeset.apply_action(changeset, :update)
      { :ok, context } = Docubit.context(docubit, contexts)
      assert context.settings[:name_prefix] == attrs.settings[:name_prefix]
    end

    test "Marking a record for deletion removes it" do
      state = docubit_fixture()
      document_version = Documents.list_document_versions(state, state_opts()) |> Enum.at(0)
      docubit = Documents.get_docubit!(document_version.body.id, %{docubit_type: true, docubits: true})
      docubit_type = Documents.get_docubit_type!("row")
      attr = DocubitFixtures.docubit_attrs(:row, document_version.id, docubit_type.id) |> Map.put(:docubit_type, docubit_type)
      first_attrs = %{ docubits: [ attr ] }
      { :ok, docubit } = Documents.update_docubit(docubit, first_attrs)
      preloaded_docubit =
        Documents.get_docubit!(docubit.id, %{ docubits: true }, %{})
        |> Map.put(:content, nil)
        |> Map.put(:through_annotation, nil)
        |> Map.put(:through_step, nil)

      docubit_to_delete =
        preloaded_docubit.docubits
        |> Enum.at(0)
        |> Map.take(Docubit.__schema__(:fields))
        |> Map.put(:delete, true)

      new_attrs = %{ docubits: [ docubit_to_delete ] }
      result = Documents.update_docubit_internal(preloaded_docubit, new_attrs)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_docubit!(docubit_to_delete.id) end
    end

    test "Marking a record for deletion removes it and reorders/readdresses the docubits" do
      state = docubit_fixture()
      document_version = Documents.list_document_versions(state, state_opts()) |> Enum.at(0)
      docubit = Documents.get_docubit!(document_version.body.id, %{docubit_type: true, docubits: true})
      docubit_type = Documents.get_docubit_type!("row")
      row_attrs =
        DocubitFixtures.docubit_attrs(:row, document_version.id, docubit_type.id)
        |> Map.put(:docubit_type, docubit_type)

      first_attrs = %{ docubits: [
        row_attrs,
        row_attrs,
        row_attrs
      ]}
      { :ok, docubit } = Documents.update_docubit(docubit, first_attrs)
      preloaded_docubit =
        Documents.get_docubit!(docubit.id, %{ docubits: true }, %{})
        |> Map.put(:content, nil)
        |> Map.put(:through_annotation, nil)
        |> Map.put(:through_step, nil)

      docubit_to_delete =
        preloaded_docubit.docubits
        |> Enum.at(1)
        |> Map.take(Docubit.__schema__(:fields))
        |> Map.put(:delete, true)

      zero = preloaded_docubit.docubits |> Enum.at(0) |> Map.take(Docubit.__schema__(:fields))
      two = preloaded_docubit.docubits |> Enum.at(2) |> Map.take(Docubit.__schema__(:fields))
      new_attrs = %{ docubits: [ zero, docubit_to_delete, two ] }
      result = Documents.update_docubit_internal(preloaded_docubit, new_attrs)
      assert Documents.get_docubit!(zero.id) |> Map.get(:order) == 0
      assert Documents.get_docubit!(two.id) |> Map.get(:order) == 1
    end
  end
end
