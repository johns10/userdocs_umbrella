defmodule UserDocs.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """
  alias UserDocs.Users

  def user_attrs(type, password)
  def user_attrs(:valid, password) do
    %{
      email: UUID.uuid4() <> "@gmail.com",
      password: "testtest",
      password_confirmation: "testtest"
    }
  end
  def user_attrs(:invalid, _password) do
    %{
      email: UUID.uuid4(),
      password: "",
      password_confirmation: ""
    }
  end

  def user(password \\ UUID.uuid4()) do
    { :ok, user } =
      user_attrs(:valid, password)
      |> Users.create_user()
    user
  end

  def team_attrs(:valid) do
    %{
      name: UUID.uuid4(),
      aws_bucket: "userdocs-test",
      aws_access_key_id: "AKIAT5VKLWBUOAYXO656",
      aws_secret_access_key: "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",
      aws_region: "us-east-2",
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
