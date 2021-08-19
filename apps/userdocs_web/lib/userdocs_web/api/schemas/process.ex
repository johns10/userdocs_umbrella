defmodule UserDocsWeb.API.Schema.Process do
  use Absinthe.Schema.Notation
  alias UserDocsWeb.API.Resolvers

  object :process do
    field :id, :id
    field :name, :string
    field :steps, list_of(:step), resolve: &Resolvers.Step.list_steps!/3
    field :last_process_instance, :process_instance, resolve: &Resolvers.ProcessInstance.get_process_instance!/3
  end

  input_object :process_input do
    field :id, non_null(:id)
    field :steps, list_of(:step_input)
    field :last_process_instance, :process_instance_input
  end
end
