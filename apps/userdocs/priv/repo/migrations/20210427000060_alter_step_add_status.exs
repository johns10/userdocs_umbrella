
defmodule UserDocs.Repo.Migrations.AlterStepAddStatus do
  use Ecto.Migration

  def change do
    alter table(:steps) do
      add :status, :string
    end
  end
end
