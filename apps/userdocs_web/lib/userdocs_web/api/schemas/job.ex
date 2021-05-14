defmodule UserDocsWeb.API.Schema.Job do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :job do
    field :id, :id
    field :name, :string
    field :status, :string

    field :warnings, list_of(:warning), resolve: &Resolvers.Warning.get_warning!/3
    field :errors, list_of(:error), resolve: &Resolvers.Error.get_error!/3
    field :process_instances, list_of(:process_instance), resolve: &Resolvers.ProcessInstance.list_process_instances/3
    field :step_instances, list_of(:step_instance), resolve: &Resolvers.StepInstance.list_step_instances/3
  end

end
