defmodule UserDocs.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :base_url, :string
      add :team_id, references(:teams, on_delete: :nothing)

      add :default_version_id, :integer

      timestamps()
    end

    create index(:projects, [:team_id])
  end
end
