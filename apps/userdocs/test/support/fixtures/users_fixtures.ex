defmodule UserDocs.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """
  alias UserDocs.Users

  def team_attrs(:valid) do
    %{
      name: "team",
      users: []
    }
  end

  def team() do
    {:ok, team } =
      team_attrs(:valid)
      |> Users.create_team()
    team
  end

end
