defmodule UserDocsWeb.API.Resolvers.StepType do

  alias UserDocs.Automation.StepType
  alias UserDocs.Automation.Step

  def get_step_type!(%Step{ step_type: %StepType{} = step_type }, _args, _resolution) do
    IO.puts("Get page call where the parent is step, and it has a preloaded step type")
    { :ok, step_type }
  end
  def get_step_type!(%Step{ step_type: nil, step_type_id: nil }, _args, _resolution) do
    IO.puts("Get page call where the parent is step, and the step_type_id is nil")
    { :ok, nil }
  end

end
