defmodule UserDocs.Repo.Migrations.AlterProcess do
  use Ecto.Migration
  require Ecto.Query

  def up do
    alter table(:processes) do
      add :project_id, references(:projects, on_delete: :nothing)
    end
    flush()
    pages =
      Ecto.Query.from(pages in UserDocs.Automation.Process)
      |> Ecto.Query.preload(:version)
      |> UserDocs.Repo.all()
      |> Enum.map(fn(process) ->
        attrs = %{project_id: process.version.project_id}
        {:ok, process} = UserDocs.Automation.update_process(process, attrs)
        process
      end)
  end

  def down do
    alter table(:processes) do
      remove :project_id, references(:projects, on_delete: :nothing)
    end
  end
end
