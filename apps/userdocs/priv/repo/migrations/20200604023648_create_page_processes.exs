defmodule UserDocs.Repo.Migrations.CreatePageProcesses do
  use Ecto.Migration

  def change do
    create table(:page_processes, primary_key: false) do
      add :page_id, references(:pages)
      add :project_id, references(:projects)
      timestamps()
    end

    create index(:page_processes, [:page_id])
    create index(:page_processes, [:project_id])
  end
end