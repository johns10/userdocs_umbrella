defmodule UserDocs.Repo.Migrations.AlterUserAddDataDirPath do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :user_data_dir_path, :string
    end
  end
end
