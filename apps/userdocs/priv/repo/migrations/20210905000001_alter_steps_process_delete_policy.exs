defmodule UserDocs.Repo.Migrations.AlterStepProcessDelete do
  use Ecto.Migration

  def up do
    drop(constraint(:steps, "steps_process_id_fkey"))
    alter table(:steps) do
      modify :process_id, references(:processes, on_delete: :delete_all), null: false
    end
  end

  def down do
    drop(constraint(:steps, "steps_process_id_fkey"))
    alter table(:steps) do
      modify :process_id, references(:processes, on_delete: :nothing), null: false
    end
  end
end
