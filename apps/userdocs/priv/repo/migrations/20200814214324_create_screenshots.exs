defmodule UserDocs.Repo.Migrations.CreateScreenshots do
  use Ecto.Migration

  def change do
    create table(:screenshots) do
      add :name, :string
      add :file_id, references(:files, on_delete: :nothing)
      add :step_id, references(:steps, on_delete: :delete_all)

      timestamps()
    end

    create index(:screenshots, [:file_id])
    create unique_index(:screenshots, [:step_id])
  end
end
