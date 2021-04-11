defmodule UserDocs.Repo.Migrations.CreateProcessInstance do
  use Ecto.Migration

  def change do
    create table(:process_instances) do
      add :order, :integer
      add :status, :string
      add :name, :string
      add :type, :string
      add :attrs, :map
      add :errors, { :array, :map }
      add :warnings, { :array, :map }
      add :expanded, :boolean
      add :job_id, references(:jobs, on_delete: :nilify_all)
      add :process_id, references(:processes, on_delete: :nilify_all)
    end

    create index(:process_instances, [:job_id])
    create index(:process_instances, [:process_id])
  end
end
