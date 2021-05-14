defmodule UserDocsWeb.API.Resolvers.ProcessInstance do
  alias UserDocs.Jobs.Job
  alias UserDocs.ProcessInstances

  def list_process_instances(%Job{ process_instances: process_instances }, _args, _resolution) when is_list(process_instances) do
    IO.puts("Got pi call")
    { :ok, process_instances }
  end

  def update_process_instance(_parent, %{id: id} = args, _resolution) do
    IO.puts("Updating Process Instances")
    IO.inspect(args)
    process_instance = ProcessInstances.get_process_instance!(id, %{ preloads: "*"})
    ProcessInstances.update_process_instance(process_instance, args)
    |> IO.inspect()
  end

end
