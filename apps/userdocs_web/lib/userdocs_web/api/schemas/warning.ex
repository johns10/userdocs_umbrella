defmodule UserDocsWeb.API.Schema.Warning do
  use Absinthe.Schema.Notation

  object :warning do
    field :message, :string
    field :name, :string
    field :stack, :string
  end
end
