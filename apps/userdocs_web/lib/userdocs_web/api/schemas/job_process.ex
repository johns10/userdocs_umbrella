defmodule UserDocsWeb.API.Schema.JobProcess do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :job_process do
    field :id, :id
    field :order, :integer
    field :process, :process, resolve: &Resolvers.Process.get_process!/3
    field :process_instance, :process_instance, resolve: &Resolvers.ProcessInstance.get_process_instance!/3

    field :warnings, list_of(:warning), resolve: &Resolvers.Warning.get_warning!/3
    field :errors, list_of(:error), resolve: &Resolvers.Error.get_error!/3
  end

  input_object :job_process_input do
    field :id, non_null(:id)
    field :process, :process_input
    field :process_instance, :process_instance_input
  end
end
