defmodule UserDocsWeb.API.Resolvers.Project do
  @moduledoc false
  alias UserDocs.Projects.Project
  alias UserDocs.Web.Page
  alias UserDocs.Automation.Process

  def get_project!(%Page{project: %Project{} = project}, _args, _resolution) do
    IO.puts("Get project call where the parent is page, and it has a preloaded project")
    {:ok, project}
  end

  def get_project!(%Process{project: %Project{} = project}, _args, _resolution) do
    IO.puts("Get project call where the parent is process, and it has a preloaded project")
    {:ok, project}
  end
end
