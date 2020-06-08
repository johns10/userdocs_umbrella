defmodule UserDocs.Repo.Migrations.CreateStepTypes do
  use Ecto.Migration

  def change do
    create table(:step_types) do
      add :name, :string
      add :args, {:array, :string}

      timestamps()
    end

  end
end
