defmodule UserDocs.Repo.Migrations.CreateDocubits do
  use Ecto.Migration

  def change do
    create table(:docubits) do
      add :type_id, :string
      add :docubit_id, references(:docubits, on_delete: :nothing)
      add :content_id, references(:content, on_delete: :nothing)
      add :file_id, references(:files, on_delete: :nothing)
      add :through_annotation_id, references(:annotations, on_delete: :nothing)
      add :through_step_id, references(:steps, on_delete: :nothing)
      add :settings, {:array, :map}
      add :address, {:array, :integer}
      add :order, :integer

      timestamps()
    end

    create index(:docubits, [:content_id])
    create index(:docubits, [:file_id])
    create index(:docubits, [:through_annotation_id])
    create index(:docubits, [:through_step_id])
  end
end
