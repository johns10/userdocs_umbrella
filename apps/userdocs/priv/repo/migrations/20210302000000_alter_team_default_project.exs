defmodule UserDocs.Repo.Migrations.ModifyDefaultProject do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      remove :default_project_id
      add :default_project, :map, from: references(:projects, on_delete: :delete_all)
    end
  end
end
