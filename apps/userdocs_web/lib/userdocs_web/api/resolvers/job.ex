defmodule UserDocsWeb.API.Resolvers.Job do

  alias UserDocs.Jobs

  def get_job!(_parent, %{id: id}, _resolution) do
    IO.puts("Get job call")
    { :ok, Jobs.get_job!(id, %{ preloads: "*" }) }
  end

  def update_job(_parent, args, _resolution) do
    IO.puts("Update Job Call")
    IO.inspect(args)
    job = Jobs.get_job!(args.id, %{ preloads: "*" })
    Jobs.update_job(job, args)
    |> IO.inspect()
  end

end
