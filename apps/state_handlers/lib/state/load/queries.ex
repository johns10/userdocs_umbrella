defmodule State.Load.Queries do

  alias UserDocs.Documents
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Web
  alias UserDocs.Users

  def team_users(user_id) do
    Users.list_team_users(%{}, %{ user_id: user_id })
  end

  def teams(user_id) do
    teams = Users.list_teams(%{}, %{ user_id: user_id })
  end

  def processes(version_id) do
    Automation.list_processes(%{}, %{version_id: version_id})
  end

  def steps(version_id) do
    Automation.list_steps(%{}, %{version_id: version_id})
  end

  def elements(version_id) do
    Web.list_elements(%{}, %{version_id: version_id})
  end

  def pages(version_id) do
    Web.list_pages(%{}, %{version_id: version_id})
  end

  def annotations(version_id) do
    Web.list_annotations(%{}, %{version_id: version_id})
  end

  def step_types do
    Automation.list_step_types()
  end

  def annotation_types do
    Web.list_annotation_types()
  end

  def content(team_id) do
    Documents.list_content(%{content_versions: true}, %{team_id: team_id})
  end

  def content_versions(team_id) do
    Documents.list_content_versions(%{language_code: true}, %{team_id: team_id})
  end

  def language_codes() do
    Documents.list_language_codes()
  end

  @spec strategies :: any
  def strategies do
    Web.list_strategies()
  end

  def versions(user_id) do
    Projects.list_versions(%{}, %{ user_id: user_id })
  end

  def projects(user_id) do
    Projects.list_projects(%{}, %{ user_id: user_id })
  end

end
