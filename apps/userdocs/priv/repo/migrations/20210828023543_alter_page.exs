defmodule UserDocs.Repo.Migrations.AlterPage do
  use Ecto.Migration
  require Ecto.Query

  def up do
    alter table(:pages) do
      add :project_id, references(:projects, on_delete: :nothing)
    end
    flush()
    pages =
      Ecto.Query.from(pages in UserDocs.Pages.Page)
      |> Ecto.Query.preload(:version)
      |> UserDocs.Repo.all()
      |> Enum.map(fn(page) ->
        attrs = %{project_id: page.version.project_id}
        {:ok, page} = UserDocs.Web.update_page(page, attrs)
        page
      end)
  end

  def down do
    alter table(:pages) do
      remove :project_id, references(:projects, on_delete: :nothing)
    end
  end
end
