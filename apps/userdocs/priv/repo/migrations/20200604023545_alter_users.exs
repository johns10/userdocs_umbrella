defmodule UserDocs.Repo.Migrations.AddDefaultTeam do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :default_team_id, references(:teams, on_delete: :delete_all)
    end
    create index(:users, [:default_team_id])
  end
end
