
defmodule UserDocs.Repo.Migrations.UserDeleteTeamUsers do
  use Ecto.Migration

  def up do
    drop constraint("team_users", "team_users_user_id_fkey")
    alter table(:team_users) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end
  end

  def down do
    drop constraint("team_users", "team_users_user_id_fkey")
    alter table(:team_users) do
      modify :user_id, references(:users, on_delete: :nothing)
    end
  end
end
