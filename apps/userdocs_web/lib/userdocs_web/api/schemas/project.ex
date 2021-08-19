defmodule UserDocsWeb.API.Schema.Project do
  @moduledoc false
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :project do
    field :id, :id
    field :name, :string
  end
end
