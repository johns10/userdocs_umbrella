defmodule UserDocsWeb.API.Schema.JobStep do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :job_step do
    field :id, :id
    field :order, :integer
    field :step, :step, resolve: &Resolvers.Step.get_step!/3
    field :step_instance, :step_instance, resolve: &Resolvers.StepInstance.get_step_instance!/3

    field :warnings, list_of(:warning), resolve: &Resolvers.Warning.get_warning!/3
    field :errors, list_of(:error), resolve: &Resolvers.Error.get_error!/3
  end
end
