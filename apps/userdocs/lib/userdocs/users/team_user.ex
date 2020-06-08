defmodule UserDocs.Users.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key false

  schema "team_users" do
    field :team_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(team_user, attrs) do
    team_user
    |> cast(attrs, [:team_id, :user_id])
    |> validate_required([])
  end
end
