
defmodule UserDocs.Repo.Migrations.DropFilesTable do
  use Ecto.Migration

  def up do
    drop table(:files)
  end

  def down do
    create table(:files) do
      add :filename, :string
      add :size, :integer
      add :content_type, :string
      add :hash, :string

      timestamps()
    end
  end
end
