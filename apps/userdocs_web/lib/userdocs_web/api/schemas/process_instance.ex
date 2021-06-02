defmodule UserDocsWeb.API.Schema.ProcessInstance do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :process_instance do
    field :id, :id
    field :name, :string
    field :order, :integer
    field :status, :string
    field :type, :string

    field :warnings, list_of(:warning), resolve: &Resolvers.Warning.get_warning!/3
    field :errors, list_of(:error), resolve: &Resolvers.Error.get_error!/3
    field :step_instances, list_of(:step_instance), resolve: &Resolvers.StepInstance.list_step_instances/3
  end

  input_object :process_instance_input do
    field :id, non_null(:id)
    field :status, non_null(:string)
  end

end
