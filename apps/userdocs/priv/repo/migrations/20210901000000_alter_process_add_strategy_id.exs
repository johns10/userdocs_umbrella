defmodule UserDocs.Repo.Migrations.AlterProcessAddStrategyId do
  use Ecto.Migration
  require Ecto.Query
  alias UserDocs.Projects
  alias UserDocs.Projects.Project

  def up do
    alter table(:projects) do
      add :strategy_id, references(:strategies, on_delete: :nothing)
    end
    flush()
    Ecto.Query.from(version in Project)
    |> UserDocs.Repo.all()
    |> Enum.map(fn(project) ->
      {:ok, _} = Projects.update_project(project, %{strategy_id: 2})
    end)
  end

  def down do
    alter table(:projects) do
      remove :strategy_id, references(:strategies, on_delete: :nothing)
    end
  end
end
