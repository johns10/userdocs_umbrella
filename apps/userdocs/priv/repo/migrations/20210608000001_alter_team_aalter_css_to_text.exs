
defmodule UserDocs.Repo.Migrations.AlterTeamAddCss do
  use Ecto.Migration

  def up do
    alter table(:teams) do
      modify :css, :text
    end
  end

  def down do
    alter table(:teams) do
      modify :css, :string
    end
  end
end
