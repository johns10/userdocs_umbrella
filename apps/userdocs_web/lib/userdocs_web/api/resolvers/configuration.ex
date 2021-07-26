defmodule UserDocsWeb.API.Resolvers.Configuration do
  @moduledoc "Graphql Resolver for Users"

  alias UserDocs.Users
  alias UserDocs.Projects

  def get_configuration!(parent, %{}, _resolution) do
    team = Users.get_team!(parent.selected_team_id)
    version = Projects.get_version!(parent.selected_version_id, %{strategy: true})
    {:ok, %{css: team.css, strategy: version.strategy.name}}
  end
end
