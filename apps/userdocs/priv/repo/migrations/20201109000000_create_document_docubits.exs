defmodule UserDocs.Repo.Migrations.CreateDocumentsDocubits do
  use Ecto.Migration

  def change do
    create table(:documents_docubits, primary_key: false) do
      add :document_id, references(:documents, on_delete: :nothing), null: false
      add :docubit_id, references(:docubits, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:documents_docubits, [:document_id])
    create index(:documents_docubits, [:docubit_id])
  end
end
