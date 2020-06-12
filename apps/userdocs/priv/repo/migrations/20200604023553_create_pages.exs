defmodule UserDocs.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :name, :string
      add :url, :string
      add :version_id, references(:versions, on_delete: :nothing)

      timestamps()
    end

    create index(:pages, [:version_id])
  end
end
