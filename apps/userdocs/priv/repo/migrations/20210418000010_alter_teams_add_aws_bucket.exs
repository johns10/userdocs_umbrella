
defmodule UserDocs.Repo.Migrations.AddDefaultProjectRelation do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :aws_bucket, :string
    end
  end
end
