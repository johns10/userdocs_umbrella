defmodule UserDocs.Repo.Migrations.CreateDocubitTypes do
  use Ecto.Migration

  def change do
    create table(:docubits) do
      add :docubit_type_id, references(:docubit_types, on_delete: :nothing)
      add :docubit_id, references(:docubits, on_delete: :nothing)
      add :content_id, references(:content, on_delete: :nothing)
      add :file_id, references(:files, on_delete: :nothing)
      add :through_annotation_id, references(:annotations, on_delete: :nothing)
      add :through_step_id, references(:steps, on_delete: :nothing)
      add :settings, :map
      add :address, {:array, :integer}
      add :order, :integer

      timestamps()
    end

    create index(:docubits, [:docubit_type_id])
    create index(:docubits, [:content_id])
    create index(:docubits, [:file_id])
    create index(:docubits, [:through_annotation_id])
    create index(:docubits, [:through_step_id])
  end
end
