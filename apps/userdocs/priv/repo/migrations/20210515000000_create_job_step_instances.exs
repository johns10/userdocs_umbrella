defmodule UserDocs.Repo.Migrations.CreateJobStep do
  use Ecto.Migration

  def change do
    create table(:job_steps, primary_key: true) do
      add :step_id, references(:steps, on_delete: :nothing), null: false
      add :job_id, references(:jobs, on_delete: :nothing), null: false
      add :step_instance_id, references(:step_instances, on_delete: :nilify_all)
      add :order, :integer
      timestamps()
    end

    create index(:job_steps, [:step_instance_id])
    create index(:job_steps, [:step_id])
    create index(:job_steps, [:job_id])
  end
end
