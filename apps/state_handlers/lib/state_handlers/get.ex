defmodule StateHandlers.Get do

  alias StateHandlers.Helpers

  def apply(state, id, schema, opts) do
    state
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> get(id, opts[:data_type], opts[:type])
  end

  def get(state, id, :list, _) when is_list(state) do
    IO.inspect(state)
    state
    |> Enum.filter(fn(o) -> o.id == id end)
    |> Enum.at(0)
  end
  def get(state, id, :map, _) when is_map(state) do
    Map.get(state, id)
  end
  def get(state, _, _, _), do: raise(RuntimeError, "StateHandlers.get got an unexpected value in state: #{state}")


  def get(state, id, :by_key, type) do
    Map.get(state, Helpers.id_key(type, id))
  end

  def get(_, _, _, opts), do: raise(RuntimeError, "State.Get failed to find a matching clause with options #{inspect(opts)}")

  def apply(_, _, opts), do: raise(RuntimeError, "State.Get.apply failed to find a matching clause with options #{inspect(opts)}")
end
