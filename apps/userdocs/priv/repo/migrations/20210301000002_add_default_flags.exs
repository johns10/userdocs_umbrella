
defmodule UserDocs.Repo.Migrations.AddDefaultFlags do
  use Ecto.Migration

  def change do
    alter table(:team_users) do
      add :default, :boolean
    end

    create unique_index(:team_users, [ :default, :team_id, :user_id ])

    alter table(:projects) do
      add :default, :boolean
    end

    create unique_index(:projects, [ :default, :team_id ])

    alter table(:versions) do
      add :default, :boolean
    end

    create unique_index(:versions, [ :default, :project_id ])
  end
end
