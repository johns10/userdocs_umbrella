defmodule UserDocs.Repo.Migrations.CreateDocumentAnnotations do
  use Ecto.Migration

  def change do
    create table(:document_annotations) do
      add :screenshot, references(:screenshots, on_delete: :nothing)
      add :annotation, references(:annotations, on_delete: :nothing)

      timestamps()
    end

    create index(:document_annotations, [:screenshot])
    create index(:document_annotations, [:annotation])
    create unique_index(:document_annotations, [:screenshot, :annotation])
  end
end
