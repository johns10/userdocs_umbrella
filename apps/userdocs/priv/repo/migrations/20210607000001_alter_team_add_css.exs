
defmodule UserDocs.Repo.Migrations.AlterTeamAddCss do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :css, :string
    end
  end
end
