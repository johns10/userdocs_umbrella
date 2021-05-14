defmodule UserDocsWeb.API.Schema.Teams do
  use Absinthe.Schema.Notation

  object :team do
    field :id, :id
    field :name, :string
  end
end
