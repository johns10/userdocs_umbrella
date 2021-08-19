defmodule UserDocsWeb.API.Schema.StepInstances do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :step_instance do
    field :id, :id
    field :order, :integer
    field :status, :string
    field :name, :string
    field :type, :string
    field :step_id, :id

    field :warnings, list_of(:warning), resolve: &Resolvers.Warning.get_warning!/3
    field :errors, list_of(:error), resolve: &Resolvers.Error.get_error!/3
    field :step, :step, resolve: &Resolvers.Step.get_step!/3
  end

  input_object :step_instance_input do
    field :id, :id
    field :status, non_null(:string)
    field :errors, list_of(:error_input)
    field :warnings, list_of(:warning_input)
  end
end
