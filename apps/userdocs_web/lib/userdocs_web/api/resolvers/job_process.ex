defmodule UserDocsWeb.API.Resolvers.JobProcess do
  alias UserDocs.Jobs.Job

  def list_job_processes!(%Job{ job_processes: job_processes }, _args, _resolution) when is_list(job_processes) do
    IO.puts("list job processes call")
    { :ok, job_processes }
  end

end
