defmodule UserDocs.Repo.Migrations.AddDefaultVersion do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :default_version_id, references(:versions, on_delete: :delete_all)
    end
    create index(:projects, [:default_version_id])
  end
end
