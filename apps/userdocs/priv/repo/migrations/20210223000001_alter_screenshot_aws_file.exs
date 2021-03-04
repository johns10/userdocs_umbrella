
defmodule UserDocs.Repo.Migrations.AddAWSFile do
  use Ecto.Migration

  def change do
    alter table(:screenshots) do
      remove :file_id, references(:files, on_delete: :nothing)
      add :aws_file, :string
    end
  end
end
