defmodule UserDocs.Repo.Migrations.RemoveProcessInstanceJobAssocs do
  use Ecto.Migration

  def change do
    drop index(:process_instances, [:job_id])

    alter table(:process_instances) do
      remove :job_id, references(:jobs, on_delete: :nilify_all)
      add :job_instance_id, references(:job_instances, on_delete: :nilify_all)
    end

    create index(:process_instances, [:job_instance_id])
  end
end
