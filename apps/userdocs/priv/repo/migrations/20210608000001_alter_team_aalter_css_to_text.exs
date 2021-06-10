
defmodule UserDocs.Repo.Migrations.AlterTeamAddCss do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      modify :css, :text
    end
  end
end
