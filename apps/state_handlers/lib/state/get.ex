defmodule State.Get do

  alias State.Helpers

  def apply(state, key, %{ type: type, location: :root, data_type: :map, strategy: :by_key }) do
    Map.get(state, Helpers.id_key(type, key))
  end

  def apply(state, key, opts = %{ location: location }) do
    state
    |> Map.get(location)
    |> State.Get.apply(key, Map.put(opts, :location, :root))
  end

  def apply(_, _, _), do: raise(RuntimeError, "State.Get failed to find a matching clause")
end
