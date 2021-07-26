defmodule UserDocsWeb.API.Schema.Override do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :override do
    field :id, :id
    field :value, :string
  end
end
