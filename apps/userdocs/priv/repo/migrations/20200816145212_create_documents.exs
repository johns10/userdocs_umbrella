defmodule UserDocs.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :name, :string
      add :title, :string
      add :docubit_id, references(:docubits, on_delete: :nothing)
      add :version_id, references(:versions, on_delete: :nothing)
      add :map, :map

      timestamps()
    end

    create index(:documents, [:docubit_id])
    create index(:documents, [:version_id])
  end
end
