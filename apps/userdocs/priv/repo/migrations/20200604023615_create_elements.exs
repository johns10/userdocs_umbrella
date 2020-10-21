defmodule UserDocs.Repo.Migrations.CreateElements do
  use Ecto.Migration

  def change do
    create table(:elements) do
      add :name, :string
      add :selector, :string
      add :page_id, references(:pages, on_delete: :nothing)
      add :strategy_id, references(:strategies, on_delete: :nothing)

      timestamps()
    end

    create index(:elements, [:page_id])
    create index(:elements, [:strategy_id])
  end
end
