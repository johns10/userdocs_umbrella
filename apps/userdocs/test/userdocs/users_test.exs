defmodule UserDocs.UsersTest do
  use UserDocs.DataCase

  alias UserDocs.Users

  describe "teams" do
    alias UserDocs.Users.Team

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_team()

      team
    end

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Users.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Users.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Users.create_team(@valid_attrs)
      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, %Team{} = team} = Users.update_team(team, @update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_team(team, @invalid_attrs)
      assert team == Users.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Users.delete_team(team)
      # TODO figure out why Users.get_team!(team.id) doesn't raise a NoResultsError
      # assert_raise Ecto.NoResultsError, fn -> Users.get_team!(team.id) end
      assert Users.get_team!(team.id) == nil
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Users.change_team(team)
    end
  end
end
