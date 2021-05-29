defmodule UserDocsWeb.API.Schema.JobInstance do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :job_instance do
    field :id, :id
    field :name, :string
    field :order, :integer
    field :status, :string
    field :type, :string

    field :warnings, list_of(:warning), resolve: &Resolvers.Warning.get_warning!/3
    field :errors, list_of(:error), resolve: &Resolvers.Error.get_error!/3

    field :step_instances, list_of(:step_instance), resolve: &Resolvers.StepInstance.list_step_instances/3
    field :process_instances, list_of(:process_instance), resolve: &Resolvers.ProcessInstance.list_process_instance/3
  end

  input_object :job_instance_input do
    field :id, :id
    field :status, :string
    field :errors, list_of(:error_input)
    field :warnings, list_of(:warning_input)
  end
end
