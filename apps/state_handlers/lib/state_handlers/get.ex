defmodule StateHandlers.Get do

  alias StateHandlers.Helpers
  alias StateHandlers.Get

  def apply(state, id, schema, []) do
    type = schema.__schema__(:source) |> String.to_atom()
    Get.apply(state, id, [ type: type, location: :root, data_type: :map, strategy: :by_type ])
  end

  def apply(state, id, [ type: type, location: :root, data_type: :map, strategy: :by_type ]) do
    state
    |> Map.get(type)
    |> Enum.filter(fn(o) -> o.id == id end)
    |> Enum.at(0)
  end

  def apply(state, id, [ type: type, location: :root, data_type: :map, strategy: :by_key ]) do
    Map.get(state, Helpers.id_key(type, id))
  end

  def apply(state, id, opts = [ location: location ]) do
    state
    |> Map.get(location)
    |> StateHandlers.Get.apply(id, Map.put(opts, :location, :root))
  end

  def apply(_, _, _), do: raise(RuntimeError, "State.Get failed to find a matching clause")
end
