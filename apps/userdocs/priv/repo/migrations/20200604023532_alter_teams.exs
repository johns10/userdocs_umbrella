
defmodule UserDocs.Repo.Migrations.AddDefaultProjectRelation do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :default_project_id, references(:projects, on_delete: :delete_all)
    end

    create index(:teams, [:default_project_id])
  end
end
