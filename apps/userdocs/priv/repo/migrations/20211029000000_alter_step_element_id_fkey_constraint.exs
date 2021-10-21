defmodule UserDocs.Repo.Migrations.AlterStepElementIdFkeyConstraint do
  use Ecto.Migration

  def up do
    drop(constraint(:steps, "steps_element_id_fkey"))
    alter table(:steps) do
      modify :element_id, references(:elements, on_delete: :nilify_all), null: true
    end
  end

  def down do
    drop(constraint(:steps, "steps_element_id_fkey"))
    alter table(:steps) do
      modify :element_id, references(:elements, on_delete: :nothing), null: true
    end
  end
end
