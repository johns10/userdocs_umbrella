defmodule UserDocsWeb.API.Resolvers.Step do

  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.Automation.Step

  def get_step!(%StepInstance{ step: %Step{} = step }, _args, _resolution) do
    IO.puts("Get step call where the parent is step_instance, and it has a preloaded step")
    { :ok, step }
  end
  def get_step!(%StepInstance{ step: nil, step_id: nil }, _args, _resolution) do
    IO.puts("Got step call where the parent is step_instance, and the step_id is nil")
    { :ok, nil }
  end

end
