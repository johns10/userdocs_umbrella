defmodule UserDocs.Repo.Migrations.AlterProcess do
  use Ecto.Migration
  require Ecto.Query

  def up do
    alter table(:projects) do
      add :strategy_id, references(:strategies, on_delete: :nothing)
    end
    flush()
    Ecto.Query.from(version in UserDocs.Projects.Version)
    |> UserDocs.Repo.all()
    |> Enum.map(fn(version) ->
      strategy_id = version.strategy_id
      attrs = %{strategy_id: strategy_id}
      {:ok, process} = UserDocs.Automation.update_process(version.process, attrs)
      process
    end)
  end

  def down do
    alter table(:projects) do
      remove :strategy_id, references(:strategies, on_delete: :nothing)
    end
  end
end
