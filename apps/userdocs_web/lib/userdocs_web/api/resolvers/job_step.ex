defmodule UserDocsWeb.API.Resolvers.JobStep do
  alias UserDocs.Jobs.Job

  def list_job_steps!(%Job{ job_steps: job_steps }, _args, _resolution) when is_list(job_steps) do
    IO.puts("list job steps call")
    { :ok, job_steps }
  end

end
