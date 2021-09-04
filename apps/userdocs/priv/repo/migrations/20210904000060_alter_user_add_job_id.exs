defmodule UserDocs.Repo.Migrations.AlterUserAddJobId do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :job_id, references(:jobs, on_delete: :nothing)
    end
  end
end
