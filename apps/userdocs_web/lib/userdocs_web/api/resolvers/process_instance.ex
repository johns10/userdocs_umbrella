defmodule UserDocsWeb.API.Resolvers.ProcessInstance do
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Jobs.JobInstance
  alias UserDocs.ProcessInstances
  alias UserDocs.Automation.Process

  def get_process_instance!(%JobProcess{ process_instance: process_instance }, _args, _resolution) do
    IO.puts("Got pi call")
    { :ok, process_instance }
  end

  def get_process_instance!(%Process{ last_process_instance: process_instance }, _args, _resolution) do
    IO.puts("Got lpi call")
    { :ok, process_instance }
  end

  def list_process_instances(%JobInstance{ process_instances: process_instances }, _args, _resolution) do
    { :ok, process_instances }
  end

  def update_process_instance(_parent, %{id: id} = args, _resolution) do
    IO.puts("Updating Process Instances")
    process_instance = ProcessInstances.get_process_instance!(id, %{ preloads: "*"})
    ProcessInstances.update_process_instance(process_instance, args)
  end

end
