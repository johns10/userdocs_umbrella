defmodule UserDocs.Repo.Migrations.AddDocubitContext do
  use Ecto.Migration

  def change do
    alter table(:docubits) do
      add :context, :map
    end
  end
end
