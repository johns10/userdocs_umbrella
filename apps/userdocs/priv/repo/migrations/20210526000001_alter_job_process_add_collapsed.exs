
defmodule UserDocs.Repo.Migrations.AlterJobProcessesAddCollapsedField do
  use Ecto.Migration

  def change do
    alter table(:job_processes) do
      add :collapsed, :boolean
    end
  end
end
