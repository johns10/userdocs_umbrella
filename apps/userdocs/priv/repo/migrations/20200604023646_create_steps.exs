defmodule UserDocs.Repo.Migrations.CreateSteps do
  use Ecto.Migration

  def change do
    create table(:steps) do
      add :order, :integer
      add :name, :string
      add :url, :string
      add :text, :string
      add :width, :integer
      add :height, :integer

      add :element_id, references(:elements, on_delete: :nothing)
      add :annotation_id, references(:annotations, on_delete: :nothing)
      add :step_type_id, references(:step_types, on_delete: :nothing)
      add :process_id, references(:processes, on_delete: :nothing)

      timestamps()
    end

    create index(:steps, [:element_id])
    create index(:steps, [:annotation_id])
    create index(:steps, [:step_type_id])
    create index(:steps, [:process_id])
  end
end
