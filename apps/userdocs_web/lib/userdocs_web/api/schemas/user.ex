defmodule UserDocsWeb.API.Schema.User do
  @moduledoc "Schema for user"
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :user do
    field :id, :id
    field :email, :string
    field :configuration, :configuration, resolve: &Resolvers.Configuration.get_configuration!/3
  end
end
