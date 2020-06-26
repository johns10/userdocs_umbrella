defmodule UserDocs.Repo.Migrations.CreateProcesses do
  use Ecto.Migration

  def change do
    create table(:processes) do
      add :name, :string
      add :page_id, references(:pages, on_delete: :nothing)
      timestamps()
    end
  end
end
