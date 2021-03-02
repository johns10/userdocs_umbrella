
defmodule UserDocs.Repo.Migrations.AddUniqueTeamUserConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:team_users, [ :team_id, :user_id ], name: :team_id_user_id_index)
  end
end
