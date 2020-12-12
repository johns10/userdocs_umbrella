defmodule UserDocs.Repo.Migrations.AddTeamDefaultLanguageCode do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :default_language_code_id, references(:language_codes, on_delete: :nothing)
    end
    create index(:teams, [:default_language_code_id])
  end
end
