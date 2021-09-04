defmodule UserDocsWeb.API.Resolvers.StepInstance do
  @moduledoc false
  alias UserDocs.Automation.Step
  alias UserDocs.Jobs.JobStep
  alias UserDocs.Jobs.JobInstance
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.StepInstances


  def list_step_instances(%JobInstance{step_instances: step_instances}, _args, _resolution)  do
    {:ok, step_instances}
  end
  def list_step_instances(%ProcessInstance{step_instances: step_instances}, _args, _resolution) when is_list(step_instances) do
    {:ok, step_instances}
  end
  def list_step_instances(%JobStep{step_instance: step_instance}, _args, _resolution)  do
    {:ok, step_instance}
  end

  def get_step_instance!(%JobStep{step_instance: step_instance}, _args, _resolution) do
    {:ok, step_instance}
  end
  def get_step_instance!(%Step{last_step_instance: step_instance}, _args, _resolution) do
    {:ok, step_instance}
  end
  def get_step_instance!(_parent, %{id: id}, _resolution) do
    step_instance = UserDocs.StepInstances.get_step_instance!(id, %{preloads: "*"})
    {:ok, step_instance}
  end

  def update_step_instance(_parent, %{id: id} = args, %{context: %{current_user: current_user}}) do
    step_instance = UserDocs.StepInstances.get_step_instance!(id, %{preloads: "*"})
    {:ok, step_instance} = StepInstances.update_step_instance(step_instance, args)
    channel =  "user:" <> to_string(current_user.id)
    UserDocsWeb.Endpoint.broadcast(channel, "update", step_instance)
    {:ok, step_instance}
  end

  def create_step_instance(_parent, %{step_id: step_id} = args, %{context: %{current_user: current_user}}) do
    step = UserDocs.Automation.get_step!(step_id)
    case Bodyguard.permit(StepInstances, :create_step_instance!, current_user, step) do
      :error -> {:error, %{message: "Unauthorized", code: 401}}
      :ok ->
        {:ok, step_instance} = StepInstances.create_step_instance(args)
        step_instance = UserDocs.StepInstances.get_step_instance!(step_instance.id, %{preloads: "*"})
        team_id = step_instance.step.page.project.team_id
        channel = UserDocsWeb.Defaults.channel(team_id)
        UserDocsWeb.Endpoint.broadcast(channel, "create", step_instance)
        IO.puts("After broadcast")
        {:ok, step_instance}
    end
  end

  def map_base64(args) do
    try do
      screenshot =
        args
        |> Map.get(:step)
        |> Map.get(:screenshot)
        |> Map.put(:base64, args.step.screenshot.base64)
        |> Map.delete(:base64)

      Kernel.put_in(args, [:step, :screenshot], screenshot)
    catch
      _ -> args
    end
  end

end
