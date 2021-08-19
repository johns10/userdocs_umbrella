defmodule UserDocsWeb.API.Schema.Override do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :override do
    field :project_id, :id
    field :url, :string
  end
end
