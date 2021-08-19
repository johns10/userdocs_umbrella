defmodule UserDocsWeb.API.Resolvers.Configuration do
  @moduledoc "Graphql Resolver for Users"

  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocs.Projects

  def get_configuration!(%User{selected_team_id: team_id, selected_version_id: version_id, overrides: overrides}, %{}, _resolution) do
    team = Users.get_team!(team_id)
    version = Projects.get_version!(version_id, %{strategy: true})
    {:ok, %{css: team.css, strategy: version.strategy.name, overrides: overrides}}
  end
end
