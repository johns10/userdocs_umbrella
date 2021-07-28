defmodule UserDocsWeb.API.Resolvers.User do
  @moduledoc "Graphql Resolver for Users"

  alias UserDocs.Users

  def get_user!(_parent, %{id: id}, %{context: %{current_user: current_user}}) do
    user = Users.get_user!(id, %{selected_team: true})
    case Bodyguard.permit(UserDocs.Users, :get_user!, current_user, user) do
      :ok -> {:ok, user}
      {:error, :unauthorized} -> {:error, %{message: "Unauthorized", status: 401}}
    end
  end
end
