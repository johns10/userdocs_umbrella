defmodule UserDocsWeb.API.Schema.Job do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :job do
    field :id, :id
    field :name, :string

    field :warnings, list_of(:warning), resolve: &Resolvers.Warning.get_warning!/3
    field :errors, list_of(:error), resolve: &Resolvers.Error.get_error!/3

    field :last_job_instance, :job_instance, resolve: &Resolvers.JobInstance.get_job_instance!/3

    field :job_processes, list_of(:job_process), resolve: &Resolvers.JobProcess.list_job_processes!/3
    field :job_steps, list_of(:job_step), resolve: &Resolvers.JobStep.list_job_steps!/3
  end

end
