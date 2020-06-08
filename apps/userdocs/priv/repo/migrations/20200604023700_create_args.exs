defmodule UserDocs.Repo.Migrations.CreateArgs do
  use Ecto.Migration

  def change do
    create table(:args) do
      add :key, :string
      add :value, :string
      add :step_id, references(:steps, on_delete: :nothing)

      timestamps()
    end

    create index(:args, [:step_id])
  end
end
