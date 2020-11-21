defmodule StateHandlers.Load do

  alias StateHandlers.Helpers

  def apply(state, data, schema, opts) do
    reload_opts = %{
      type: opts[:type], location: opts[:location], schema: schema,
      strategy: opts[:strategy], loader: opts[:loader]
    }
    with assigns <- Helpers.maybe_access_assigns(state),
      location_data <- Helpers.maybe_access_location(assigns, opts[:location]),
      type <- Helpers.maybe_access_type(state, opts[:strategy], schema),
      data <- load_data(type, data, opts[:data_type], opts[:strategy]),
      state <- reassign(state, location_data, data, reload_opts)
    do
      state
    end
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

  def reassign(state, _location_data, data, %{ schema: schema, location: nil, loader: loader }) do
    loader.(state, Helpers.type(schema), data)
  end
  def reassign(state, _location_data, data, %{ schema: schema, location: nil, loader: nil }) do
    Map.put(state, Helpers.type(schema), data)
  end
  def reassign(state, location_data, data, %{ schema: schema, location: location, loader: loader })
  when is_atom(location) do
    location_data = Map.put(location_data, Helpers.type(schema), data)
    loader.(state, location, location_data)
  end
  def reassign(state, location_data, data, %{ schema: schema, location: location, loader: nil })
  when is_atom(location) do
    location_data = Map.put(location_data, Helpers.type(schema), data)
    Map.put(state, location, location_data)
  end
end
