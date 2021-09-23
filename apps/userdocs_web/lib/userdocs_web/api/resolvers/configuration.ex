defmodule UserDocsWeb.API.Resolvers.Configuration do
  @moduledoc "Graphql Resolver for Users"

  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocs.Projects

  def get_configuration!(%User{selected_team_id: team_id, selected_project_id: project_id, overrides: overrides}, %{}, _resolution) do
    team = Users.get_team!(team_id)
    project = Projects.get_project!(project_id, %{preloads: [strategy: true]})
    strategy = project.strategy || %{name: "css"}
    {:ok, %{css: team.css, overrides: overrides, strategy: project.strategy.name}}
  end
end
