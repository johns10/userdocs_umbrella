defmodule UserDocs.Repo.Migrations.CreateJobInstance do
  use Ecto.Migration

  def change do
    create table(:job_instances) do
      add :order, :integer
      add :status, :string
      add :name, :string
      add :type, :string
      add :errors, { :array, :map }
      add :warnings, { :array, :map }
      add :expanded, :boolean
      add :job_id, references(:jobs, on_delete: :nilify_all)
      add :started_at, :naive_datetime
      add :finished_at, :naive_datetime
    end

    create index(:job_instances, [:job_id])
  end
end
