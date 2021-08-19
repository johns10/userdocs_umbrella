defmodule UserDocsWeb.API.Resolvers.Project do
  @moduledoc false
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version

  def get_project!(%Version{project: %Project{} = project}, _args, _resolution) do
    IO.puts("Get project call where the parent is version, and it has a preloaded project")
    {:ok, project}
  end
end
