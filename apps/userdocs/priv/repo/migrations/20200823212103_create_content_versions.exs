defmodule UserDocs.Repo.Migrations.CreateContentVersions do
  use Ecto.Migration

  def change do
    create table(:content_versions) do
      add :language_code, :string
      add :name, :string
      add :body, :text
      add :language_code_id, references(:language_codes, on_delete: :nothing)
      add :content_id, references(:content, on_delete: :nothing)
      add :version_id, references(:versions, on_delete: :nothing)

      timestamps()
    end

    create index(:content_versions, [:content_id, :version_id, :language_code_id])
  end
end
