defmodule UserDocs.Repo.Migrations.CreateScreenshots do
  use Ecto.Migration

  def change do
    create table(:screenshots) do
      add :name, :string
      add :step_id, references(:steps, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:screenshots, [:step_id])
  end
end
