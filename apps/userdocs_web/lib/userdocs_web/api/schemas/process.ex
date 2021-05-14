defmodule UserDocsWeb.API.Schema.Process do
  use Absinthe.Schema.Notation

  object :process do
    field :id, :id
    field :name, :string
  end
end
