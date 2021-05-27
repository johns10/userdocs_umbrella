defmodule UserDocs.Automation.Process.Safe do

  def apply(step, handlers \\ %{})
  def apply(process = %UserDocs.Automation.Process{}, handlers) do
    base_safe(process)
    |> maybe_safe_steps(handlers[:step], process.steps, handlers)
    |> maybe_safe_process_instance(handlers[:process_instance], process.last_process_instance, handlers)
  end
  def apply(nil, _), do: nil

  defp base_safe(process) do
    %{
      id: process.id,
      order: process.order,
      name: process.name
    }
  end

  defp maybe_safe_steps(process, _, %Ecto.Association.NotLoaded{}, _), do: process
  defp maybe_safe_steps(process, nil, _, _), do: process
  defp maybe_safe_steps(process, handler, steps, handlers) do
    steps = Enum.map(steps,
      fn(step) ->
        handler.(step, handlers)
      end)
    Map.put(process, :steps, steps)
  end

  defp maybe_safe_process_instance(process, _, %Ecto.Association.NotLoaded{}, _), do: process
  defp maybe_safe_process_instance(process, nil, _, _), do: process
  defp maybe_safe_process_instance(process, handler, process_instance, handlers) do
    Map.put(process, :last_process_instance, handler.(process_instance, handlers))
  end
end
