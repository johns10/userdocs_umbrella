defmodule UserDocsWeb.API.Resolvers.Override do
  @moduledoc "Graphql Resolver for Users"

  alias UserDocs.Users.User

  def get_override!(%{overrides: overrides}, %{}, _resolution) do
    IO.puts("Got override call where the parent is map")
    {:ok, overrides}
  end
end
