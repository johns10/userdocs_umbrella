defmodule StateHandlers.Load do

  alias StateHandlers.Helpers

  def apply(state, data, schema, opts) do
    # IO.inspect("Loading #{Helpers.type(schema)} data into #{opts[:location]}")
    reload_opts = %{
      type: opts[:type], location: opts[:location], schema: schema,
      strategy: opts[:strategy], loader: opts[:loader]
    }
    with assigns <- Helpers.maybe_access_assigns(state),
      location_data <- Helpers.maybe_access_location(assigns, opts[:location]),
      type <- Helpers.maybe_access_type(location_data, opts[:strategy], schema),
      data <- load_data(type, data, opts[:data_type], opts[:strategy]),
      state <- Helpers.reassign(state, location_data, data, reload_opts)
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
end
