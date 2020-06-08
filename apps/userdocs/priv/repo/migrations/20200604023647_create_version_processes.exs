defmodule UserDocs.Repo.Migrations.CreateVersionProcesses do
  use Ecto.Migration

  def change do
    create table(:version_processes, primary_key: false) do
      add :version_id, references(:versions)
      add :process_id, references(:processes)
      timestamps()
    end

    create index(:version_processes, [:version_id])
    create index(:version_processes, [:process_id])
  end
end
