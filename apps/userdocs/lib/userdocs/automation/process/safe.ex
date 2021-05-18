defmodule UserDocs.Automation.Process.Safe do

  def apply(step, handlers \\ %{})
  def apply(process = %UserDocs.Automation.Process{}, handlers) do
    base_safe(process)
    |> maybe_safe_steps(handlers[:step], process.steps, handlers)
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
end
