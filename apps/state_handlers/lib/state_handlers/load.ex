defmodule StateHandlers.Load do

  alias StateHandlers.Helpers

  def apply(state, data, schema, opts) do
    # IO.inspect("Loading #{Helpers.type(schema)} data into #{opts[:location]}")
    loader = opts[:loader] || &Map.put/3
    { state, nil, nil }
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> load_data(data, opts[:data_type], opts[:strategy])
    |> Helpers.maybe_put_in_location(schema, opts[:strategy], opts[:location])
    |> Helpers.reload(schema, loader, opts[:strategy], opts[:location])
  end

  def load_data({ state, location_data, target }, data, data_type, strategy) do
    { state, location_data, load_data(target, data, data_type, strategy) }
  end
  def load_data(state, data, :map, :by_key) do
    Enum.reduce(data, state,
      fn(d, s) ->
        Map.put(s, Helpers.id_key(d), d)
      end)
  end
  def load_data(state, data, :map, :by_type) do
    Enum.reduce(data, state,
      fn({ k, v }, s) ->
        Map.put(s, k, v)
      end)
  end
  def load_data(_, data, :list, :by_type) do
    data
  end
end
