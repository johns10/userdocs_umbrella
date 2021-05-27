defmodule UserDocs.ProcessInstances.ProcessInstance.Safe do

  alias UserDocs.ProcessInstances.ProcessInstance

  def apply(process_instance, handlers \\ %{})
  def apply(process_instance = %ProcessInstance{}, _handlers) do
    base_safe(process_instance)
  end
  def apply(nil, _), do: nil

  defp base_safe(process_instance) do
    Map.take(process_instance, ProcessInstance.__schema__(:fields))
  end
end
