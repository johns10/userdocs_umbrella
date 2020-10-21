defmodule UserDocs.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  import Ecto.Changeset


  alias UserDocs.Users.Team
  alias UserDocs.Users.TeamUser

  schema "users" do
    pow_user_fields()

    field :default_team_id, :integer

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
    |> cast(attrs, [:default_team_id])
  end

  def teams(user = %UserDocs.Users.User{}, %{ teams: teams, team_users: team_users }) do
    teams(user.id, teams, team_users)
  end
  def teams(user_id, teams, team_users) when is_integer(user_id) do
    IO.puts("Teams")
    teams_users =
      Enum.filter(team_users, fn(tu) -> tu.user_id == user_id end)

    team_ids =
      Enum.map(team_users, fn(tu) -> Map.get(tu, :team_id) end)

    Enum.filter(teams, fn(t) -> t.id in team_ids end)
  end
end
