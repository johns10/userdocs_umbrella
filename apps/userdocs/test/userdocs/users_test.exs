defmodule UserDocs.UsersTest do
  use UserDocs.DataCase

  alias UserDocs.Users
  alias UserDocs.UsersFixtures

  @opts [data_type: :list, strategy: :by_type, loader: &Phoenix.LiveView.assign/3]
  describe "users" do
    alias UserDocs.Users.User
    alias UserDocs.UsersFixtures
    alias UserDocs.ProjectsFixtures
    alias UserDocs.WebFixtures


    test "list_users/0 returns all teams" do
      user = UsersFixtures.user()
      result =
        Users.list_users()
        |> Enum.at(0)
        |> Map.delete(:password)
      assert result == Map.delete(user, :password)
    end

    test "get_user!/1 returns the team with given id" do
      user = UsersFixtures.user()
      result =
        Users.get_user!(user.id)
        |> Map.delete(:password)
      assert result == Map.delete(user, :password)
    end

    test "create_user/1 with valid data creates a user" do
      attrs = UsersFixtures.user_attrs(:valid)
      assert {:ok, %User{} = user} = Users.create_user(attrs)
      assert user.email == attrs.email
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(UsersFixtures.user_attrs(:invalid))
    end

    test "update_user/2 with valid data updates the user" do
      password = UUID.uuid4()
      user = UsersFixtures.user(password)
      attrs = UsersFixtures.user_attrs(:valid)
      attrs =
        attrs
        |> Map.put(:current_password, password)

      {:ok, %User{} = user} = Users.update_user(user, attrs)

      assert user.unconfirmed_email == attrs.email
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = UsersFixtures.user()
      attrs = UsersFixtures.user_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, attrs)
      result =
        Users.get_user!(user.id)
        |> Map.delete(:password)
      assert result == Map.delete(user, :password)
    end

    test "delete_user/1 deletes the user" do
      user = UsersFixtures.user()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = UsersFixtures.team()
      assert %Ecto.Changeset{} = Users.change_team(team)
    end

    test "get_user/2 with preload teams and state returns preloaded user" do
      user = UsersFixtures.user()
      team = UsersFixtures.team()
      team_user = UsersFixtures.team_user(user.id, team.id)
      preloads = [teams: :teams]
      state = %{teams: [team], users: [user], team_users: [team_user]}
      result = Users.get_user!(user.id, preloads, [], state, @opts)
      assert result.teams == [team]
    end

    test "get_user/2 with preload list: teams and state returns preloaded user" do
      user = UsersFixtures.user()
      team_one = UsersFixtures.team()
      team_two = UsersFixtures.team()
      preloads = [teams: [:teams]]
      team_user_one = UsersFixtures.team_user(user.id, team_one.id)
      team_user_two = UsersFixtures.team_user(user.id, team_two.id)
      state = %{teams: [team_one, team_two], users: [user], team_users: [team_user_one, team_user_two]}
      result = Users.get_user!(user.id, preloads, [], state, @opts)
      assert result.teams == [team_one, team_two]
    end

    test "get_user/2 with preload teams + projects and state returns preloaded user" do
      user = UsersFixtures.user()
      team = UsersFixtures.team()
      team_user = UsersFixtures.team_user(user.id, team.id)
      strategy = WebFixtures.strategy()
      project = ProjectsFixtures.project(team.id, strategy.id)
      preloads = [teams: [:teams, [teams: :projects]]]
      state = %{teams: [team], users: [user], team_users: [team_user], projects: [project]}
      result = Users.get_user!(user.id, preloads, [], state, @opts)
      assert project == result.teams |> Enum.at(0) |> Map.get(:projects) |> Enum.at(0)
    end

    test "get_user/2 with preload teams, projects and state returns preloaded user" do
      user = UsersFixtures.user()
      team = UsersFixtures.team()
      team_user = UsersFixtures.team_user(user.id, team.id)
      strategy = WebFixtures.strategy()
      project = ProjectsFixtures.project(team.id, strategy.id)
      preloads = [teams: [:teams, [teams: :projects], [teams: :projects]]]
      state = %{teams: [team], users: [user], team_users: [team_user], projects: [project]}
      result = Users.get_user!(user.id, preloads, [], state, @opts)
      assert project == result.teams |> Enum.at(0) |> Map.get(:projects) |> Enum.at(0)
    end

    test "update_user/2 with valid project overrides updates the user" do
      password = UUID.uuid4()
      user = UsersFixtures.user(password)
      team = UsersFixtures.team()
      _team_user = UsersFixtures.team_user(user.id, team.id)
      strategy = WebFixtures.strategy()
      project = ProjectsFixtures.project(team.id, strategy.id)
      overrides = [%{project_id: project.id, url: "https://www.google.com/"}]
      attrs = UsersFixtures.user_attrs(:valid)
      attrs = attrs |> Map.put(:overrides, overrides)

      {:ok, %User{} = user} = Users.update_user_options(user, attrs)
      assert user.overrides |> Enum.at(0) |> Map.get(:project_id) == project.id

      UserDocs.Projects.delete_project(project)
      {:error, changeset} = Users.update_user_options(user, attrs)
      {error, _} = changeset.changes.overrides |> Enum.at(1) |> Map.get(:errors) |> Keyword.get(:project_id)
      assert error == "This project ID does exist. Pick a new project."
    end
  end

  describe "teams" do
    alias UserDocs.Users.Team

    @valid_attrs %{name: "some name", users: []}
    @update_attrs %{name: "some updated name", users: []}
    @invalid_attrs %{name: nil, users: []}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_team()

      team
    end

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Users.list_teams(%{users: true}) == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Users.get_team!(team.id, %{users: true}) == team
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
      assert_raise Ecto.NoResultsError, fn -> Users.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Users.change_team(team)
    end
  end
end
