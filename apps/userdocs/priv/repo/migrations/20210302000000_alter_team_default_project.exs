defmodule UserDocs.Repo.Migrations.ModifyDefaultProject do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      remove :default_project_id, references(:projects, on_delete: :delete_all)
      add :default_project, :map
    end
  end
end
