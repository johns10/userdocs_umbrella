defmodule UserDocsWeb.API.Schema.Version do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :version do
    field :id, :id
    field :name, :string
    field :project, :project, resolve: &Resolvers.Project.get_project!/3
  end
end
