
defmodule UserDocs.Repo.Migrations.AddTeamAwsBucket do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :aws_bucket, :string
    end
  end
end
