defmodule UserDocsWeb.API.Resolvers.StepInstance do
  alias UserDocs.Users
  alias UserDocs.StepInstances
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.Jobs.JobStep
  alias UserDocs.Automation.Step

  def list_step_instances(%ProcessInstance{ step_instances: step_instances }, _args, _resolution) when is_list(step_instances) do
    IO.inspect("Listing step instances for a process instance")
    { :ok, step_instances }
  end


  def list_step_instances(%JobStep{ step_instance: step_instance }, _args, _resolution)  do
    IO.inspect("Listing step instances for a job")
    { :ok, step_instance }
  end

  """
  def list_step_instances(_parent, _args, _resolution) do
    { :ok, UserDocs.StepInstances.list_step_instances() }
  end
  """

  def get_step_instance!(%JobStep{ step_instance: step_instance}, _args, resolution) do
    { :ok, step_instance }
  end
  def get_step_instance!(%Step{ last_step_instance: step_instance }, _args, _resolution) do
    { :ok, step_instance }
  end
  def get_step_instance!(_parent, %{id: id}, resolution) do
    step_instance = UserDocs.StepInstances.get_step_instance!(id, %{ preloads: "*"})
    { :ok, step_instance }
  end


  def update_step_instance(_parent, %{id: id} = args, resolution) do
    step_instance = StepInstances.get_step_instance!(args.id, %{ preloads: "*"})
    StepInstances.update_step_instance(step_instance, map_base64(args))
  end


  def map_base64(args) do
    try do
      screenshot =
        args
        |> Map.get(:step)
        |> Map.get(:screenshot)
        |> Map.put(:base64, args.step.screenshot.base64)
        |> Map.delete(:base64)

      Kernel.put_in(args, [ :step, :screenshot ], screenshot)
    catch
      _ -> args
    end
  end

end
