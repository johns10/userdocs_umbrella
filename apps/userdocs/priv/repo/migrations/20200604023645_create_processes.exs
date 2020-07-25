defmodule UserDocs.Repo.Migrations.CreateProcesses do
  use Ecto.Migration

  def change do
    create table(:processes) do
      add :order, :integer
      add :name, :string
      add :version_id, references(:versions, on_delete: :nothing)
      timestamps()
    end
  end
end
