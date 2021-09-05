defmodule UserDocs.Repo.Migrations.AlterProcessJobProcessDelete do
  use Ecto.Migration

  def up do
    drop(constraint(:job_processes, "job_processes_process_id_fkey"))
    alter table(:job_processes) do
      modify :process_id, references(:processes, on_delete: :delete_all), null: false
    end
  end

  def down do
    drop(constraint(:job_processes, "job_processes_process_id_fkey"))
    alter table(:job_processes) do
      modify :process_id, references(:processes, on_delete: :nothing), null: false
    end
  end
end
