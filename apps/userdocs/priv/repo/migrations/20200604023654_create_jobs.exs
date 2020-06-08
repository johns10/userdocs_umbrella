defmodule UserDocs.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :job_type, :string
      add :page_id, references(:pages, on_delete: :nothing)
      add :version_id, references(:versions, on_delete: :nothing)

      timestamps()
    end

    create index(:jobs, [:page_id])
    create index(:jobs, [:version_id])
  end
end
