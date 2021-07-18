
defmodule UserDocs.Repo.Migrations.AlterUserAddProjectOverrides do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :project_url_overrides, :jsonb, default: "[]"
    end
  end
end
