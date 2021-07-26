defmodule UserDocsWeb.API.Schema.Configuration do
  @moduledoc false
  use Absinthe.Schema.Notation

  alias UserDocsWeb.API.Resolvers

  object :configuration do
    field :id, :id
    field :image_path, :string
    field :strategy, :string
    field :user_data_dir_path, :string
    field :css, :string
    field :overrides, :override, resolve: &Resolvers.Override.get_override!/3
  end
end
