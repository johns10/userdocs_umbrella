defmodule UserDocsWeb.API.Schema.AnnotationType do
  use Absinthe.Schema.Notation

  object :annotation_type do
    field :id, :id
    field :name, :string
  end
end
