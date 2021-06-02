defmodule UserDocsWeb.API.Schema.Element do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :element do
    field :id, :id
    field :name, :string
    field :selector, :string
    field :strategy, :strategy, resolve: &Resolvers.Strategy.get_strategy!/3
  end
end
