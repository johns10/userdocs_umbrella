defmodule UserDocs.Repo.Migrations.CreateStepInstance do
  use Ecto.Migration

  def change do
    create table(:step_instances) do
      add :order, :integer
      add :status, :string
      add :name, :string
      add :type, :string
      add :attrs, :map
      add :errors, { :array, :map }
      add :warnings, { :array, :map }
      add :expanded, :boolean
      add :job_id, references(:jobs, on_delete: :nilify_all)
      add :step_id, references(:steps, on_delete: :nilify_all)
      add :process_instance_id, references(:process_instances, on_delete: :nilify_all)
    end

    create index(:step_instances, [:job_id])
    create index(:step_instances, [:step_id])
    create index(:step_instances, [:process_instance_id])
  end
end
