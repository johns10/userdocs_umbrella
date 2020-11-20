defmodule UserDocs.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """
  alias UserDocs.Users

  def user_attrs(:valid) do
    password = UUID.uuid4()
    %{
      email: UUID.uuid4() <> "@gmail.com",
      password: password,
      password_confirmation: password
    }
  end
  def user_attrs(:invalid) do
    %{
      email: UUID.uuid4(),
      password: "",
      password_confirmation: ""
    }
  end

  def user() do
    { :ok, user } =
      user_attrs(:valid)
      |> Users.create_user()
    user
  end

  def team_attrs(:valid) do
    %{
      name: UUID.uuid4(),
      users: []
    }
  end

  def team() do
    {:ok, team } =
      team_attrs(:valid)
      |> Users.create_team()
    team
  end

  def team_user(user_id, team_id) do
    { :ok, team_user } =
      team_user_attrs(:valid, user_id, team_id)
      |> Users.create_team_user()
      team_user
  end

  def team_user_attrs(:valid, user_id, team_id) do
    %{
      team_id: team_id,
      user_id: user_id
    }
  end

end
