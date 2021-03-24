defmodule UserDocs.Automation.Process.Safe do

  def apply(step, handlers \\ %{})
  def apply(process = %UserDocs.Automation.Process{}, handlers) do
    base_safe(process)
    |> maybe_safe_steps(handlers[:steps], process.steps, handlers)
  end
  def apply(nil, _), do: nil

  defp base_safe(process) do
    %{
      id: process.id,
      order: process.order,
      name: process.name
    }
  end

  defp maybe_safe_steps(step, %Ecto.Association.NotLoaded{}, _, _), do: step
  defp maybe_safe_steps(step, nil, _, _), do: step
  defp maybe_safe_steps(step, handler, steps, handlers) do
    Map.put(step, :steps, handler.(steps, handlers))
  end
end
