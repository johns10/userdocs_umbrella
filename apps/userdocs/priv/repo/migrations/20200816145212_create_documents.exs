defmodule UserDocs.Repo.Migrations.CreateDocumentVersions do
  use Ecto.Migration

  def change do
    create table(:document_versions) do
      add :name, :string
      add :title, :string
      add :docubit_id, references(:docubits, on_delete: :delete_all)
      add :version_id, references(:versions, on_delete: :nothing)
      add :map, :map

      timestamps()
    end

    create index(:document_versions, [:docubit_id])
    create index(:document_versions, [:version_id])
  end
end
