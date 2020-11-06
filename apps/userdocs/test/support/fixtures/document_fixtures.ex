defmodule UserDocs.DocumentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Documents

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
end
