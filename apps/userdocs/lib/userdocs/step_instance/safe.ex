defmodule UserDocs.StepInstances.StepInstance.Safe do

  alias UserDocs.StepInstances.StepInstance

  def apply(step_instance, handlers \\ %{})
  def apply(step_instance = %StepInstance{}, _handlers) do
    base_safe(step_instance)
  end
  def apply(nil, _), do: nil
  def apply(%Ecto.Association.NotLoaded{}, _), do: nil

  defp base_safe(step_instance) do
    Map.take(step_instance, StepInstance.__schema__(:fields))
  end
end
