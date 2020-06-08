defmodule UserDocs.Repo.Migrations.CreateProcesses do
  use Ecto.Migration

  def change do
    create table(:processes) do
      add :name, :string
      timestamps()
    end
  end
end
