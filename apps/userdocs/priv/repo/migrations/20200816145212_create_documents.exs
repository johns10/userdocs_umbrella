defmodule UserDocs.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :name, :string
      add :title, :string
      add :project_id, references(:projects, on_delete: :delete_all)
      timestamps()
    end

    create index(:documents, [:project_id])
  end
end
