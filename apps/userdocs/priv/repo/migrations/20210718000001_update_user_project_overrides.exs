
defmodule UserDocs.Repo.Migrations.AlterUserAddProjectOverrides do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :overrides, :jsonb, default: "[]"
    end
  end
end
