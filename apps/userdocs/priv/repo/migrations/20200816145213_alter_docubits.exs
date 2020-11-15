defmodule UserDocs.Repo.Migrations.AddDocumentRelation do
  use Ecto.Migration

  def change do
    alter table(:docubits) do
      add :document_id, references(:documents, on_delete: :nothing)
    end

    create index(:docubits, [:document_id])
  end
end
