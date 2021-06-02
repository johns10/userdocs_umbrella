defmodule UserDocsWeb.API.Schema.Page do
  use Absinthe.Schema.Notation

  object :page do
    field :id, :id
    field :order, :integer
    field :name, :string
    field :url, :string
  end
end
