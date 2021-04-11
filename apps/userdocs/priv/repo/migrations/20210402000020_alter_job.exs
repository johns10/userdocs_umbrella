defmodule UserDocs.Repo.Migrations.AlterJob do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      remove :job_type, :string
      remove :page_id, references(:pages, on_delete: :nothing)
      remove :version_id, references(:versions, on_delete: :nothing)

      add :order, :integer
      add :status, :string
      add :name, :string
      add :errors, { :array, :map }
      add :warnings, { :array, :map }

      add :team_id, references(:teams, on_delete: :nothing)
    end

    create index(:jobs, [:team_id])
  end
end
