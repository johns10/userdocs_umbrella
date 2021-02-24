defmodule UserDocs.Repo.Migrations.AddUserSelections do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :selected_team_id, references(:teams, on_delete: :nothing)
      add :selected_project_id, references(:projects, on_delete: :nothing)
      add :selected_version_id, references(:versions, on_delete: :nothing)
    end
    create index(:users, [:selected_team_id])
    create index(:users, [:selected_project_id])
    create index(:users, [:selected_version_id])
  end
end
