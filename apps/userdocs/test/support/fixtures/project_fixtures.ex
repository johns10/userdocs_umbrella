defmodule UserDocs.ProjectsFixtures do

  alias UserDocs.Projects

  def project(team_id) do
    {:ok, project } =
      project_attrs(:valid, team_id)
      |> Projects.create_project()
      project
  end
  def version(project_id \\ nil, strategy_id \\ nil) do
    {:ok, version } =
      version_attrs(:valid, project_id, strategy_id)
      |> Projects.create_version()
      version
  end

  def project_attrs(type, team_id \\ nil)
  def project_attrs(:valid, team_id) do
    %{
      base_url: UUID.uuid4(),
      name: UUID.uuid4(),
      team_id: team_id
    }
  end
  def project_attrs(:default, team_id) do
    %{
      base_url: UUID.uuid4(),
      name: UUID.uuid4(),
      team_id: team_id,
      default: true
    }
  end
  def project_attrs(:invalid, team_id) do
    %{
      base_url: nil,
      name: nil,
      team_id: team_id
    }
  end

  def version_attrs(type, project_id \\ nil, strategy_id \\ nil)
  def version_attrs(:valid, project_id, strategy_id) do
    %{
      name: UUID.uuid4(),
      project_id: project_id,
      strategy_id: strategy_id
    }
  end
  def version_attrs(:invalid, project_id, strategy_id) do
    %{
      name: nil,
      project_id: project_id,
      strategy_id: strategy_id
    }
  end

end
