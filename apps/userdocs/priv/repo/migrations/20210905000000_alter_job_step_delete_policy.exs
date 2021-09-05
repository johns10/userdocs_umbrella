defmodule UserDocs.Repo.Migrations.AlterJobStepStepIdOnDelete do
  use Ecto.Migration

  def up do
    drop(constraint(:job_steps, "job_steps_step_id_fkey"))
    alter table(:job_steps) do
      modify :step_id, references(:steps, on_delete: :delete_all), null: false
    end
  end

  def down do
    drop(constraint(:job_steps, "job_steps_step_id_fkey"))
    alter table(:job_steps) do
      modify :step_id, references(:steps, on_delete: :nothing), null: false
    end
  end
end
