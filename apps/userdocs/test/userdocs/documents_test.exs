defmodule UserDocs.DocumentsTest do
  use UserDocs.DataCase
  alias UserDocs.Documents
  alias UserDocs.Projects
  alias UserDocs.StateFixtures
  alias UserDocs.DocumentFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.MediaFixtures
  alias UserDocs.AutomationFixtures
  alias UserDocs.DocubitFixtures

  describe "content" do
    alias UserDocs.Documents.Content

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def content_fixture(attrs \\ %{}) do
      team = create_team()

      {:ok, content} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:team_id, team.id)
        |> Documents.create_content()

      content
    end

    test "list_content/0 returns all content" do
      content = content_fixture()
      assert Documents.list_content() == [content]
    end

    test "get_content!/1 returns the content with given id" do
      content = content_fixture()
      assert Documents.get_content!(content.id) == content
    end

    test "create_content/1 with valid data creates a content" do
      attrs = Map.put(@valid_attrs, :team_id, Map.get(create_team(), :id))
      assert {:ok, %Content{} = content} = Documents.create_content(attrs)
      assert content.name == "some name"
    end

    test "create_content/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_content(@invalid_attrs)
    end

    test "update_content/2 with valid data updates the content" do
      content = content_fixture()
      assert {:ok, %Content{} = content} = Documents.update_content(content, @update_attrs)
      assert content.name == "some updated name"
    end

    test "update_content/2 with invalid data returns error changeset" do
      content = content_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_content(content, @invalid_attrs)
      assert content == Documents.get_content!(content.id)
    end

    test "delete_content/1 deletes the content" do
      content = content_fixture()
      assert {:ok, %Content{}} = Documents.delete_content(content)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_content!(content.id) end
    end

    test "change_content/1 returns a content changeset" do
      content = content_fixture()
      assert %Ecto.Changeset{} = Documents.change_content(content)
    end
  end

  describe "document" do
    alias UserDocs.Documents.Document
    alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures

    test "list_documents/0 returns all documents" do
      document = DocumentFixtures.document()
      assert Documents.list_documents() == [document]
    end

    test "list_documents/2 returns all documents" do
      opts = [ data_type: :list, strategy: :by_type ]
      state = DocumentFixtures.state()
      document = DocumentFixtures.document()
      assert Documents.list_documents(state, opts) == state.documents
    end

    test "list_documents/2 returns all documents with document_versions preloaded" do
      opts = [ data_type: :list, strategy: :by_type, preloads: [ :document_versions ] ]
      state = DocumentFixtures.state()
      document = Enum.at(Documents.list_documents(state, opts), 0)
      assert document.document_versions == state.document_versions
    end

    test "get_document!/1 returns the document with given id" do
      document = DocumentFixtures.document()
      assert Documents.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document" do
      attrs = DocumentFixtures.document_attrs(:valid)
      assert {:ok, %Document{} = document} = Documents.create_document(attrs)
      assert document.name == attrs.name
    end

    test "create_document/1 with invalid data returns error changeset" do
      attrs = DocumentFixtures.document_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Documents.create_document(attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = DocumentFixtures.document()
      attrs = DocumentFixtures.document_attrs(:valid)
      assert {:ok, %Document{} = document} = Documents.update_document(document, attrs)
      assert document.name == attrs.name
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = DocumentFixtures.document()
      attrs = DocumentFixtures.document_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Documents.update_document(document, attrs)
      assert document == Documents.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = DocumentFixtures.document()
      assert {:ok, %Document{}} = Documents.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = DocumentFixtures.document()
      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end

  describe "document_versions" do
    alias UserDocs.Documents.DocumentVersion
    alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures

    def state_opts() do
      [ data_type: :list, strategy: :by_type, location: :data ]
    end

    def document_version_fixture() do
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

    test "list_document_versions/0 returns all document_versions" do
      state = document_version_fixture()
      document_versions = Documents.list_document_versions(state, state_opts())
      assert Documents.list_document_versions(%{ body: true }) == document_versions
    end

    test "get_document_version!/1 returns the document_version with given id" do
      state = document_version_fixture()
      d = Documents.list_documents(state, state_opts()) |> Enum.at(0)
      v = Projects.list_versions(state, state_opts()) |> Enum.at(0)
      document_version = DocumentFixtures.document_version(d.id, v.id)
      assert Documents.get_document_version!(document_version.id, %{ body: true }) == document_version
    end

    test "create_document_version/1 with valid data creates a document_version" do
      state = document_version_fixture()
      docubit_type = Documents.get_docubit_type!("container")
      d = Documents.list_documents(state, state_opts()) |> Enum.at(0)
      v = Projects.list_versions(state, state_opts()) |> Enum.at(0)
      attrs = DocumentFixtures.document_version_attrs(:valid, d.id, v.id)
      assert {:ok, %DocumentVersion{} = document_version} = Documents.create_document_version(attrs)
      assert document_version.name == attrs.name
      assert document_version.version_id == v.id
      assert document_version.document_id == d.id
    end

    test "create_document_version/1 with invalid data returns error changeset" do
      state = document_version_fixture()
      d = Documents.list_documents(state, state_opts()) |> Enum.at(0)
      v = Projects.list_versions(state, state_opts()) |> Enum.at(0)
      attrs = DocumentFixtures.document_version_attrs(:invalid, d.id, v.id)
      assert {:error, %Ecto.Changeset{}} = Documents.create_document_version(attrs)
    end

    test "update_document_version/2 with valid data updates the document_version" do
      state = document_version_fixture()
      dv = Documents.list_document_versions(state, state_opts()) |> Enum.at(0)
      d = Documents.list_documents(state, state_opts()) |> Enum.at(0)
      v = Projects.list_versions(state, state_opts()) |> Enum.at(0)
      attrs = DocumentFixtures.document_version_attrs(:valid, d.id, v.id)
      assert {:ok, %DocumentVersion{} = document_version} = Documents.update_document_version(dv, attrs)
      assert document_version.name == attrs.name
    end

    test "update_document_version/2 with invalid data returns error changeset" do
      state = document_version_fixture()
      dv = Documents.list_document_versions(state, state_opts()) |> Enum.at(0)
      d = Documents.list_documents(state, state_opts()) |> Enum.at(0)
      v = Projects.list_versions(state, state_opts()) |> Enum.at(0)
      attrs = DocumentFixtures.document_version_attrs(:invalid, d.id, v.id)
      assert {:error, %Ecto.Changeset{}} = Documents.update_document_version(dv, attrs)
      assert dv == Documents.get_document_version!(dv.id, %{ body: true })
    end

    test "delete_document_version/1 deletes the document_version" do
      state = document_version_fixture()
      dv = Documents.list_document_versions(state, state_opts()) |> Enum.at(0)
      assert {:ok, %DocumentVersion{}} = Documents.delete_document_version(dv)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_document_version!(dv.id) end
    end

    test "change_document_version/1 returns a document_version changeset" do
      state = document_version_fixture()
      dv = Documents.list_document_versions(state, state_opts()) |> Enum.at(0)
      assert %Ecto.Changeset{} = Documents.change_document_version(dv)
    end
  end

  describe "content_versions" do
    alias UserDocs.Documents.ContentVersion

    @valid_attrs %{
      body: "some body",
      name: "some name",
    }
    @update_attrs %{
      body: "some updated body",
      name: "some updated name",
    }
    @invalid_attrs %{
      body: nil,
      language_code: nil,
      name: nil,
      content_id: nil
    }
    @language_code_attrs %{ code: "EN-us" }
    @team_attrs %{name: "team", users: []}
    @content_attrs %{ name: "cname" }
    @version_attrs %{name: "some name"}

    def content_version_fixture(attrs \\ %{}, lc_attrs \\ @language_code_attrs) do
      {:ok, content_version} =
        attrs
        |> Enum.into(@valid_attrs)
        |> required_attrs(create_required)
        |> Documents.create_content_version()

      content_version
    end

    def create_required() do
      {
        create_language_code(),
        create_content(create_team()),
        create_version(),
      }
    end

    def create_team() do
      {:ok, team } =
        @team_attrs
        |> UserDocs.Users.create_team()
      team
    end

    def create_version() do
      {:ok, version } =
        @version_attrs
        |> UserDocs.Projects.create_version()
      version
    end

    def create_content(team) do
      {:ok, content } =
        @content_attrs
        |> Map.put(:team_id, team.id)
        |> Documents.create_content()
      content
    end

    def create_language_code() do
      {:ok, language_code } =
        @language_code_attrs
        |> Documents.create_language_code()
      language_code
    end

    def required_attrs(attrs, {language_code, content, version}) do
      attrs
      |> Map.put(:language_code_id, language_code.id)
      |> Map.put(:content_id, content.id)
      |> Map.put(:version_id, version.id)
    end

    test "list_content_versions/0 returns all content_versions" do
      content_version = content_version_fixture()
      assert Documents.list_content_versions() == [content_version]
    end

    test "get_content_version!/1 returns the content_version with given id" do
      content_version = content_version_fixture()
      assert Documents.get_content_version!(content_version.id) == content_version
    end

    test "create_content_version/1 with valid data creates a content_version" do
      attrs =
        @valid_attrs
        |> required_attrs(create_required)

      assert {:ok, %ContentVersion{} = content_version} =
        Documents.create_content_version(attrs)

      assert content_version.body == "some body"
      assert content_version.name == "some name"
    end

    test "create_content_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_content_version(@invalid_attrs)
    end

    test "update_content_version/2 with valid data updates the content_version" do
      content_version = content_version_fixture()
      assert {:ok, %ContentVersion{} = content_version} = Documents.update_content_version(content_version, @update_attrs)
      assert content_version.body == "some updated body"
      assert content_version.name == "some updated name"
    end

    test "update_content_version/2 with invalid data returns error changeset" do
      content_version = content_version_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_content_version(content_version, @invalid_attrs)
      assert content_version == Documents.get_content_version!(content_version.id)
    end

    test "delete_content_version/1 deletes the content_version" do
      content_version = content_version_fixture()
      assert {:ok, %ContentVersion{}} = Documents.delete_content_version(content_version)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_content_version!(content_version.id) end
    end

    test "change_content_version/1 returns a content_version changeset" do
      content_version = content_version_fixture()
      assert %Ecto.Changeset{} = Documents.change_content_version(content_version)
    end
  end

  describe "language_codes" do
    alias UserDocs.Documents.LanguageCode

    @valid_attrs %{code: "some code"}
    @update_attrs %{code: "some updated code"}
    @invalid_attrs %{code: nil }

    def language_code_fixture(attrs \\ %{}) do
      {:ok, language_code} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Documents.create_language_code()

      language_code
    end

    test "list_language_codes/0 returns all language_codes" do
      language_code = language_code_fixture()
      assert Documents.list_language_codes() == [language_code]
    end

    test "get_language_code!/1 returns the language_code with given id" do
      language_code = language_code_fixture()
      assert Documents.get_language_code!(language_code.id) == language_code
    end

    test "create_language_code/1 with valid data creates a language_code" do
      assert {:ok, %LanguageCode{} = language_code} = Documents.create_language_code(@valid_attrs)
      assert language_code.code == "some code"
    end

    test "create_language_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_language_code(@invalid_attrs)
    end

    test "update_language_code/2 with valid data updates the language_code" do
      language_code = language_code_fixture()
      assert {:ok, %LanguageCode{} = language_code} = Documents.update_language_code(language_code, @update_attrs)
      assert language_code.code == "some updated code"
    end

    test "update_language_code/2 with invalid data returns error changeset" do
      language_code = language_code_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_language_code(language_code, @invalid_attrs)
      assert language_code == Documents.get_language_code!(language_code.id)
    end

    test "delete_language_code/1 deletes the language_code" do
      language_code = language_code_fixture()
      assert {:ok, %LanguageCode{}} = Documents.delete_language_code(language_code)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_language_code!(language_code.id) end
    end

    test "change_language_code/1 returns a language_code changeset" do
      language_code = language_code_fixture()
      assert %Ecto.Changeset{} = Documents.change_language_code(language_code)
    end
  end

  describe "docubit_types" do
    alias UserDocs.Documents
    alias UserDocs.Documents.DocubitType
    alias UserDocs.DocubitFixtures

    test "list_docubit_types/0 returns all docubit_types" do
      docubit_type = DocubitFixtures.docubit_type(:container)
      assert Documents.list_docubit_types() == [docubit_type]
    end

    test "get_docubit_type!/1 returns the docubit_type with given id" do
      docubit_type = DocubitFixtures.docubit_type(:container)
      assert Documents.get_docubit_type!(docubit_type.id) == docubit_type
    end

    test "create_docubit_types/1 with container data creates a docubit_types" do
      attrs = DocubitFixtures.docubit_type_attrs(:ol)
      assert {:ok, %DocubitType{} = docubit_type} = Documents.create_docubit_type(attrs)
      assert docubit_type.name == "ol"
    end

    test "create_docubit_types/1 with invalid data returns error changeset" do
      attrs = DocubitFixtures.docubit_type_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Documents.create_language_code(attrs)
    end

    test "update_docubit_types/2 with valid data updates the docubit_type" do
      docubit_type = DocubitFixtures.docubit_type(:container)
      attrs = DocubitFixtures.docubit_type_attrs(:row)
      assert {:ok, %DocubitType{} = docubit_type} = Documents.update_docubit_type(docubit_type, attrs)
      assert docubit_type.name == "row"
    end

    test "update_docubit_type/2 with invalid data returns error changeset" do
      docubit_type = DocubitFixtures.docubit_type(:container)
      attrs = DocubitFixtures.docubit_type_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Documents.update_docubit_type(docubit_type, attrs)
      assert docubit_type == Documents.get_docubit_type!(docubit_type.id)
    end

    test "delete_docubit_type/1 deletes the docubit_type" do
      docubit_type = DocubitFixtures.docubit_type(:container)
      assert {:ok, %DocubitType{}} = Documents.delete_docubit_type(docubit_type)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_docubit_type!(docubit_type.id) end
    end

    test "change_docubit_type/1 returns a docubit_type changeset" do
      docubit_type = DocubitFixtures.docubit_type(:container)
      assert %Ecto.Changeset{} = Documents.change_docubit_type(docubit_type)
    end

    test "get_docubit_type!/1 returns a docubit type" do
      DocubitFixtures.create_docubit_types()
      docubit_type = Documents.get_docubit_type!("container")
      assert docubit_type.name == "container"
    end
  end
end
