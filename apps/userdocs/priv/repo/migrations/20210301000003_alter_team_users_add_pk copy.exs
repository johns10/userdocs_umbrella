
defmodule UserDocs.Repo.Migrations.AddTeamUsersPK do
  use Ecto.Migration

  def change do
    alter table(:team_users) do
      add(:id, :bigserial, primary_key: true)
    end
  end
end
