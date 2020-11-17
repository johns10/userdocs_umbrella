defmodule UserDocs.Repo.Migrations.CreateDocumentVersionsDocubits do
  use Ecto.Migration

  def change do
    create table(:document_versions_docubits, primary_key: false) do
      add :document_version_id, references(:document_versions, on_delete: :nothing), null: false
      add :docubit_id, references(:docubits, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:document_versions_docubits, [:document_version_id])
    create index(:document_versions_docubits, [:docubit_id])
  end
end
