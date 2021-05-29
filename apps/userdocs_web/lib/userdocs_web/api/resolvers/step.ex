defmodule UserDocsWeb.API.Resolvers.Step do

  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.Process
  alias UserDocs.Jobs.JobStep

  def list_steps!(%Process{ steps: steps }, _args, _resolution) when is_list(steps) do
    IO.puts("Get step call where the parent is process")
    { :ok, steps }
  end

  def get_step!(%StepInstance{ step: %Step{} = step }, _args, _resolution) do
    IO.puts("Get step call where the parent is step_instance, and it has a preloaded step")
    { :ok, step }
  end
  def get_step!(%StepInstance{ step: nil, step_id: nil }, _args, _resolution) do
    IO.puts("Got step call where the parent is step_instance, and the step_id is nil")
    { :ok, nil }
  end

  def get_step!(%JobStep{ step: step }, _args, _resolution) do
    IO.puts("Got step call where the parent is jobstep, and the step_id is nil")
    { :ok, step }
  end
end
