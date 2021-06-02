defmodule UserDocs.Repo.Migrations.CreateJobProcess do
  use Ecto.Migration

  def change do
    create table(:job_processes, primary_key: true) do
      add :process_id, references(:processes, on_delete: :nothing), null: false
      add :job_id, references(:jobs, on_delete: :nothing), null: false
      add :process_instance_id, references(:process_instances, on_delete: :nilify_all)
      add :order, :integer
      timestamps()
    end

    create index(:job_processes, [:process_instance_id])
    create index(:job_processes, [:process_id])
    create index(:job_processes, [:job_id])
  end
end
