defmodule UserDocsWeb.API.Schema.StepType do
  use Absinthe.Schema.Notation

  object :step_type do
    field :id, :id
    field :name, :string
  end
end
