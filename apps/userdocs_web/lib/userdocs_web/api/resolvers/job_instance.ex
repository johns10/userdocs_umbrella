defmodule UserDocsWeb.API.Resolvers.JobInstance do
  alias UserDocs.Jobs.Job

  def get_job_instance!(%Job{ last_job_instance: job_instance }, _args, _resolution) do
    IO.puts("list job processes call")
    { :ok, job_instance }
  end

end
