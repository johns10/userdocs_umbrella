defmodule UserDocs.Repo.Migrations.AlterUserAddBrowserSessionPid do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :browser_session, :string
    end
  end
end
