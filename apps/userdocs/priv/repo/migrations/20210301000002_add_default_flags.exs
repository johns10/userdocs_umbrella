
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

    alter table(:versions) do
      add :default, :boolean
    end

  end
end
