defmodule UserDocs.DocumentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Documents

  def empty_document() do
    document_attrs = %{ name: "test", title: "Test" }
    { :ok, empty_document } = Documents.create_document(document_attrs)
    empty_document
  end

  def content(team) do
    {:ok, object } =
      content_attrs(team.id, :valid)
      |> Documents.create_content()
    object
  end


  def content_attrs(team_id, :valid) do
    %{
      name: UUID.uuid4(),
      team_id: team_id
    }
  end

  def document_attrs(:valid) do
    %{ name: "test", title: "Test" }
  end
end
