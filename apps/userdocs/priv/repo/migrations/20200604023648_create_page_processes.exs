defmodule UserDocs.Repo.Migrations.CreatePageProcesses do
  use Ecto.Migration

  def change do
    create table(:page_processes, primary_key: false) do
      add :page_id, references(:pages)
      add :process_id, references(:processes)
      timestamps()
    end

    create index(:page_processes, [:page_id])
    create index(:page_processes, [:process_id])
  end
end