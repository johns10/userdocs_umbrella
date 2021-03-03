defmodule UserDocs.Repo.Migrations.AddUserSelections do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :default_team, :map
      modify :default_team_id, :integer, from: references(:teams, on_delete: :delete_all)
      add :selected_team, :map
      add :selected_team_id, :integer
      add :selected_project, :map
      add :selected_project_id, :integer
      add :selected_version, :map
      add :selected_version_id, :integer
    end
  end
end
