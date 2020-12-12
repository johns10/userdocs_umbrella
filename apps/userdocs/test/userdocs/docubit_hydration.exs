defmodule UserDocs.DocumentHydrationTest do
  use UserDocs.DataCase

  describe "document_version_body" do
    alias UserDocs.Documents.Docubit, as: Docubit

    alias UserDocs.DocubitFixtures
    alias UserDocs.WebFixtures
    alias UserDocs.UsersFixtures
    alias UserDocs.AutomationFixtures
    alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures
    alias UserDocs.MediaFixtures
    alias UserDocs.StateFixtures

    alias UserDocs.Automation
    alias UserDocs.Web
    alias UserDocs.Media
    alias UserDocs.Documents

    def annotation_with_content(state) do
      content =
        Documents.list_content(state, state_opts())
        |> Enum.at(0)
      annotation =
        Web.list_annotations(state, state_opts())
        |> Enum.at(0)
        |> Map.put(:content_id, content.id)
        |> Map.put(:content, content)
    end

    def prepare_docubit(state) do
      Documents.list_docubits(state, state_opts())
      |> Enum.at(0)
      |> Docubit.preload_type()
    end

    def state_opts() do
      [ data_type: :list, strategy: :by_type, location: :data ]
    end
    def docubit_fixture() do
      opts = state_opts()
      %{}
      |> StateFixtures.base_state(opts)
      |> DocumentFixtures.state(opts)
      |> WebFixtures.state(opts)
      |> MediaFixtures.add_file_to_state(opts)
      |> AutomationFixtures.state(opts)
      |> MediaFixtures.add_screenshot_to_state(opts)
      |> DocubitFixtures.state(opts)
    end

    test "hydrate adds content and content id on a docubit" do
      state = docubit_fixture()
      content = Documents.list_content(state, state_opts()) |> Enum.at(0)
      docubit = prepare_docubit(state) |> Docubit.hydrate(content)
      assert docubit.content == content
    end

    test "hydrate adds content and through_annotation on a docubit" do
      state = docubit_fixture()
      annotation = annotation_with_content(state)
      docubit = prepare_docubit(state) |> Docubit.hydrate(annotation)
      assert docubit.through_annotation == annotation
      assert docubit.through_annotation_id == annotation.id
      assert docubit.content == annotation.content
      assert docubit.content_id == annotation.content_id
    end

    test "hydrate adds content, through_annotation, and through_step on a p docubit when a step is added" do
      state = docubit_fixture()
      annotation = annotation_with_content(state)
      step =
        Automation.list_steps(state, state_opts())
        |> Enum.at(0)
        |> Map.put(:annotation_id, annotation.id)
        |> Map.put(:annotation, annotation)
      docubit = prepare_docubit(state) |> Docubit.hydrate(step)
      assert docubit.through_step == step
      assert docubit.through_step_id == step.id
      assert docubit.through_annotation == step.annotation
      assert docubit.through_annotation_id == step.annotation.id
      assert docubit.content == step.annotation.content
      assert docubit.content_id == step.annotation.content_id
    end

    test "hydrate adds file and through_step on a img docubit when a step is added" do
      state = docubit_fixture()
      file = Media.list_files(state, state_opts()) |> Enum.at(0)
      dv = Documents.list_document_versions(state, state_opts()) |> Enum.at(0)
      docubit = DocubitFixtures.docubit(:img, dv.id) |> Docubit.preload_type()
      screenshot =
        Media.list_screenshots(state, state_opts())
        |> Enum.at(0)
        |> Map.put(:file, file)
      step =
        Automation.list_steps(state, state_opts())
        |> Enum.at(0)
        |> Map.put(:screenshot, screenshot)
      docubit = docubit |> Docubit.hydrate(step)
      assert docubit.through_step.screenshot == step.screenshot
      assert docubit.through_step.screenshot.file == step.screenshot.file
    end
  end
end
