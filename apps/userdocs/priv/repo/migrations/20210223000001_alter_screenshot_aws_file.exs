
defmodule UserDocs.Repo.Migrations.AddAWSFile do
  use Ecto.Migration

  def up do
    alter table(:screenshots) do
      add :aws_file, :string
      remove :file_id, references(:files, on_delete: :nothing)
    end
    create index(:screenshots, [:file_id])
  end

  def down do
    alter table(:screenshots) do
      remove :aws_file, :string
      add :file_id, references(:files, on_delete: :nothing)
    end
    create index(:screenshots, [:file_id])
  end
end
