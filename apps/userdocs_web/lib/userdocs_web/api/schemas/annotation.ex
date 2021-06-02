defmodule UserDocsWeb.API.Schema.Annotation do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :annotation do
    field :id, :id
    field :name, :string
    field :label, :string
    field :x_orientation, :string
    field :y_orientation, :string
    field :size, :integer
    field :color, :string
    field :thickness, :integer
    field :x_offset, :integer
    field :y_offset, :integer
    field :font_size, :integer
    field :font_color, :string

    field :annotation_type, :annotation_type, resolve: &Resolvers.AnnotationType.get_annotation_type!/3
  end
end
