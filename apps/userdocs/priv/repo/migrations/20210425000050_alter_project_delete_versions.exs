
defmodule UserDocs.Repo.Migrations.AlterProjectDeleteVersion do
  use Ecto.Migration

  def up do
    drop constraint("versions", "versions_project_id_fkey")
    alter table(:versions) do
      modify :project_id, references(:projects, on_delete: :delete_all)
    end
  end

  def down do
    drop constraint("versions", "versions_project_id_fkey")
    alter table(:versions) do
      modify :project_id, references(:projects, on_delete: :nothing)
    end
  end
end
