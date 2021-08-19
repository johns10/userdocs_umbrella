defmodule UserDocsWeb.API.Resolvers.Job do

  alias UserDocs.Jobs

  def get_job!(_parent, %{id: id}, _resolution) do
    IO.puts("Get job call")
    {
      :ok,
      Jobs.get_job!(id, %{ preloads: [ steps: true, processes: true, last_job_instance: true ]})
      |> Jobs.prepare_for_execution()
    }
  end

  def update_job(_parent, args, _resolution) do
    IO.puts("Update Job Call")
    job =
      Jobs.get_job!(args.id, %{ preloads: [ steps: true, processes: true, last_job_instance: true ]})
      |> Jobs.prepare_for_execution()
    Jobs.update_job(job, args)
  end

end
