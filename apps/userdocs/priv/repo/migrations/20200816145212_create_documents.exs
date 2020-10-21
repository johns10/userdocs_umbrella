defmodule UserDocs.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :name, :string
      add :title, :string
      add :version_id, references(:versions, on_delete: :nothing)
      add :body, :map

      timestamps()
    end

    create index(:documents, [:version_id])
  end
end
