defmodule UserDocs.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :default_project_id, :integer

      timestamps()
    end

    create unique_index(:teams, [:name])
  end
end
