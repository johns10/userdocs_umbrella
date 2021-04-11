
defmodule UserDocs.Repo.Migrations.AddDefaultProjectRelation do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :aws_region, :string
      add :aws_access_key_id, :binary
      add :aws_access_key_id_hash, :binary
      add :aws_secret_access_key, :binary
      add :aws_secret_access_key_hash, :binary
    end
  end
end
