defmodule UserDocsWeb.API.Schema.Project do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :project do
    field :id, :id
    field :name, :string
    field :base_url, :string
  end
end
