defmodule UserDocs.Repo.Migrations.AddDocumentVersionRelation do
  use Ecto.Migration

  def change do
    alter table(:docubits) do
      add :document_version_id, references(:document_versions, on_delete: :delete_all)
    end

    create index(:docubits, [:document_version_id])
  end
end
