defmodule StateHandlers.Load do

  alias StateHandlers.Helpers

  def apply(state, data, [ data_type: :map, strategy: :by_key ]) do
    Enum.reduce(data, state,
      fn(d, s) ->
        Map.put(s, Helpers.id_key(d), d)
      end)
  end

  def apply(state, data, [ data_type: :map, strategy: :by_type, type: type, loader: loader ]) do
    loader.(state, type, list_to_map(data))
  end
  def apply(state, data, [ data_type: :map, strategy: :by_type, type: type ]) do
    Map.put(state, type, list_to_map(data))
  end

  def apply(state, data, [ data_type: :list, type: type, loader: loader ]) do
    loader.(state, type, data)
  end
  def apply(state, data, [ data_type: :list, type: type ]), do: Map.put(state, type, data)

  defp list_to_map(data) do
    Enum.reduce(data, %{},
      fn(object, acc) ->
        Map.put(acc, object.id, object)
      end
    )
  end
end
