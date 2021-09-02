defmodule UserDocsWeb.API.Resolvers.ProcessInstance do
  @moduledoc false
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Jobs.JobInstance
  alias UserDocs.ProcessInstances
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.Automation
  alias UserDocs.Automation.Process

  def get_process_instance!(%JobProcess{process_instance: process_instance}, _args, _resolution) do
    IO.puts("Got pi call")
    {:ok, process_instance}
  end

  def get_process_instance!(%Process{last_process_instance: process_instance}, _args, _resolution) do
    IO.puts("Got lpi call")
    {:ok, process_instance}
  end

  def list_process_instances(%JobInstance{process_instances: process_instances}, _args, _resolution) do
    {:ok, process_instances}
  end

  def update_process_instance(_parent, %{id: id} = args, %{context: %{current_user: current_user}}) do
    {:ok, process_instance} =
      ProcessInstances.get_process_instance!(id, %{preloads: "*"})
      |> ProcessInstances.update_process_instance(args)

    channel =  "user:" <> to_string(current_user.id)
    UserDocsWeb.Endpoint.broadcast(channel, "update", process_instance)
    {:ok, process_instance}
  end

  def create_process_instance(_parent, %{process_id: process_id, status: _status}, %{context: %{current_user: current_user}}) do
    process = Automation.get_process!(process_id, %{preloads: "*"})
    {:ok, %ProcessInstance{id: id}} = ProcessInstances.create_process_instance_from_process(process, 1)
    process_instance = ProcessInstances.get_process_instance!(id, %{preloads: "*"})

    channel =  "user:" <> to_string(current_user.id)
    UserDocsWeb.Endpoint.broadcast(channel, "create", process_instance)
    Enum.each(process_instance.step_instances, fn(step_instances) ->
      UserDocsWeb.Endpoint.broadcast(channel, "create", step_instances)
    end)

    {:ok, process_instance}
  end

  def create_process_instance(_parent, %{process_id: process_id}, %{context: %{current_user: _current_user}}) do
    process = Automation.get_process!(process_id, %{preloads: "*"})
    {:ok, %ProcessInstance{id: id}} = ProcessInstances.create_process_instance_from_process(process, 1)
    process_instance = ProcessInstances.get_process_instance!(id, %{preloads: "*"})
    {:ok, process_instance}
  end
end
