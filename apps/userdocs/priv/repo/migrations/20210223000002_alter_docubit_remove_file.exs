
defmodule UserDocs.Repo.Migrations.AlterDocubitRemoveFileAddScreenshot do
  use Ecto.Migration

  def change do
    alter table(:docubits) do
      remove :file_id, references(:files, on_delete: :nothing)
      add :screenshot_id, references(:screenshots, on_delete: :nothing)
    end
    create index(:docubits, [:screenshot_id])
  end
end
