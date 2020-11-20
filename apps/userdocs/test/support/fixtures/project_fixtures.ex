defmodule UserDocs.ProjectsFixtures do

  alias UserDocs.Projects

  def project(team_id) do
    {:ok, project } =
      project_attrs(:valid, team_id)
      |> Projects.create_project()
      project
  end
  def version(project_id) do
    {:ok, version } =
      version_attrs(:valid, project_id)
      |> Projects.create_version()
      version
  end

  def project_attrs(:valid, team_id \\ nil) do
    %{
      base_url: UUID.uuid4(),
      name: UUID.uuid4(),
      team_id: team_id
    }
  end

  def version_attrs(:valid, project_id \\ nil) do
    %{
      name: UUID.uuid4(),
      project_id: project_id
    }
  end

end
