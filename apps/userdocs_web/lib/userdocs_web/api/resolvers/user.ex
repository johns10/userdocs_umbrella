defmodule UserDocsWeb.API.Resolvers.User do
  @moduledoc "Graphql Resolver for Users"

  alias UserDocs.Users

  def get_user!(_parent, %{id: id}, _resolution) do
    {:ok, Users.get_user!(id, %{selected_team: true})}
  end
end
