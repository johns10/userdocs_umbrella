defmodule UserDocs.DocumentVersionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Documents
  alias UserDocs.StateFixtures

  def state() do
    state = StateFixtures.base_state()
    v = Enum.at(state.versions, 0)
    d = document()
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

  def content(team) do
    {:ok, object } =
      content_attrs(team.id, :valid)
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
      name: "",
      title: "",
      project_id: project_id
    }
  end

  def content_attrs(team_id, :valid) do
    %{
      name: UUID.uuid4(),
      team_id: team_id
    }
  end

  def document_version_attrs(:valid, document_id \\ nil, version_id \\ nil) do
    %{
      name: UUID.uuid4(),
      document_id: document_id,
      version_id: version_id
    }
  end
end
