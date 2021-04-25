defmodule UserDocs.DocumentVersionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Users
  alias UserDocs.Documents
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion
  alias UserDocs.StateFixtures
  alias UserDocs.DocubitFixtures

  alias UserDocs.Projects

  def state(state, opts) do
    opts =
      opts
      |> Keyword.put(:types, [ Document, DocumentVersion, Content, ContentVersion ])

    v = Projects.list_versions(state, opts) |> Enum.at(0)
    p = Projects.list_projects(state, opts) |> Enum.at(0)
    document = document(p.id)
    document_version = document_version(document.id, v.id)
    t = Users.list_teams(state, opts) |> Enum.at(0)
    content = content(t)

    state
    |> StateHandlers.initialize(opts)
    |> StateHandlers.load([document], Document, opts)
    |> StateHandlers.load([document_version], DocumentVersion, opts)
    |> StateHandlers.load([content], Content, opts)

  end

  def state() do
    state = StateFixtures.base_state()
    DocubitFixtures.create_docubit_types()
    v = Enum.at(state.versions, 0)
    d = document(state.project.id)
    dv = document_version(d.id, v.id)
    state
    |> Map.put(:document, d)
    |> Map.put(:document_version, dv)
    |> Map.put(:documents, [ d ])
    |> Map.put(:document_versions, [ dv ])
  end

  def document(project_id \\ nil) do
    document_attrs = document_attrs(:valid, project_id)
    { :ok, document } = Documents.create_document(document_attrs)
    document
  end

  def document_version(document_id \\ nil, version_id \\ nil) do
    empty_document_version(document_id, version_id)
  end

  def empty_document_version(document_id \\ nil, version_id \\ nil) do
    document_version_attrs = document_version_attrs(:valid, document_id, version_id)
    { :ok, empty_document_version } = Documents.create_document_version(document_version_attrs)
    empty_document_version
  end

  def content(team_id) do
    {:ok, object } =
      content_attrs(:valid, team_id)
      |> Documents.create_content()
    object
  end

  def document_attrs(type, project_id \\ nil)
  def document_attrs(:valid, project_id) do
    %{
      name: UUID.uuid4(),
      title: UUID.uuid4(),
      project_id: project_id
    }
  end
  def document_attrs(:invalid, project_id) do
    %{
      name: None,
      title: None,
      project_id: project_id
    }
  end

  def content_attrs(:valid, team_id) do
    %{
      name: UUID.uuid4(),
      team_id: team_id
    }
  end
  def content_attrs(:invalid, team_id) do
    %{
      name: nil,
      team_id: team_id
    }
  end

  def document_version_attrs(type, document_id \\ nil, version_id \\ nil)
  def document_version_attrs(:valid, document_id, version_id) do
    %{
      name: UUID.uuid4(),
      document_id: document_id,
      version_id: version_id
    }
  end

  def document_version_attrs(:invalid, document_id, version_id) do
    %{
      name: None,
      document_id: document_id,
      version_id: version_id
    }
  end
end
