defmodule UserDocs.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.ChangesetHelpers
  alias UserDocs.Users.Team
  alias UserDocs.Users.TeamUser
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version

  schema "users" do
    pow_user_fields()

    field :default_team_id, :integer
    embeds_one :default_team, Team

    field :selected_team_id, :integer
    embeds_one :selected_team, Team
    field :selected_project_id, :integer
    embeds_one :selected_project, Project
    field :selected_version_id, :integer
    embeds_one :selected_version, Version

    has_many :team_users, TeamUser

    many_to_many :teams,
      Team,
      join_through: TeamUser,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> cast(attrs, [:default_team_id, :selected_team_id, :selected_project_id, :selected_version_id])
  end

  def change_options(user, attrs) do
    user
    |> cast(attrs, [ :default_team_id, :selected_team_id, :selected_project_id, :selected_version_id ])
    |> cast_assoc(:team_users)
    |> ChangesetHelpers.check_only_one_default(:team_users)
  end

  def change_selections(user, attrs) do
    user
    |> cast(attrs, [:default_team_id, :selected_team_id, :selected_project_id, :selected_version_id])
  end

  def preload_teams(user = %UserDocs.Users.User{}, %{ teams: teams, team_users: team_users }) do
    Map.put(user, :teams, teams(user.id, teams, team_users))
  end
  def teams(user = %UserDocs.Users.User{}, %{ teams: teams, team_users: team_users }) do
    teams(user.id, teams, team_users)
  end
  def teams(user_id, teams, team_users) when is_integer(user_id) do
    _teams_users =
      Enum.filter(team_users, fn(tu) -> tu.user_id == user_id end)

    team_ids =
      Enum.map(team_users, fn(tu) -> Map.get(tu, :team_id) end)

    Enum.filter(teams, fn(t) -> t.id in team_ids end)
  end

  def preload_projects(user = %UserDocs.Users.User{ teams: teams }, %{ projects: projects }) do
    teams =
      Enum.map(teams,
        fn(t) ->
          Map.put(t, :projects, Enum.filter(projects, fn(p) -> p.team_id == t.id end))
        end)
    Map.put(user, :teams, teams)
  end

  def preload_versions(user = %UserDocs.Users.User{ teams: teams }, %{ versions: versions }) do
    teams =
      Enum.map(teams,
        fn(t) ->
          Map.put(t, :projects, Enum.map(t.projects,
            fn(p) ->
              Map.put(p, :versions, Enum.filter(versions, fn(v) -> v.project_id == p.id end))
            end))
        end)
    Map.put(user, :teams, teams)
  end
end
