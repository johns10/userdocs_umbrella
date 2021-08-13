defmodule UserDocs.Repo.Migrations.AddTeamUserType do
  use Ecto.Migration

  def change do
    alter table(:team_users) do
      add :type, :string
    end
  end
end
