defmodule UserDocsWeb.API.Schema.Strategy do
  use Absinthe.Schema.Notation

  object :strategy do
    field :id, :id
    field :name, :string
  end
end
