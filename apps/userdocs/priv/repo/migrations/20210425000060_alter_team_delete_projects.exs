
defmodule UserDocs.Repo.Migrations.TeamDeleteTeamUsers do
  use Ecto.Migration

  def up do
    drop constraint("team_users", "team_users_team_id_fkey")
    alter table(:team_users) do
      modify :team_id, references(:teams, on_delete: :delete_all)
    end
    drop constraint("projects", "projects_team_id_fkey")
    alter table(:projects) do
      modify :team_id, references(:teams, on_delete: :delete_all)
    end
  end

  def down do
    drop constraint("team_users", "team_users_team_id_fkey")
    alter table(:team_users) do
      modify :team_id, references(:teams, on_delete: :nothing)
    end
    drop constraint("projects", "projects_team_id_fkey")
    alter table(:projects) do
      modify :team_id, references(:teams, on_delete: :nothing)
    end
  end
end
