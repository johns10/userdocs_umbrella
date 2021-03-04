
defmodule UserDocs.Repo.Migrations.AddAWSFile do
  use Ecto.Migration

  def change do
    alter table(:screenshots) do
      add :aws_file, :string
    end
  end
end
