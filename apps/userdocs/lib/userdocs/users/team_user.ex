defmodule UserDocs.Users.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Users.User
  alias UserDocs.Users.Team

  @primary_key false

  schema "team_users" do
    belongs_to :team, Team
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(team_user, attrs) do
    team_user
    |> cast(attrs, [:team_id, :user_id])
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
    |> validate_required([])
  end
end
