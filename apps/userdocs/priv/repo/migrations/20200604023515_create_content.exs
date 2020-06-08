defmodule UserDocs.Repo.Migrations.CreateContent do
  use Ecto.Migration

  def change do
    create table(:content) do
      add :name, :string
      add :description, :string
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end

    create index(:content, [:team_id])
  end
end
