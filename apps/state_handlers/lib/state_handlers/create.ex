defmodule StateHandlers.Create do

  alias StateHandlers.Helpers

  def apply(state, data, opts) when is_struct(data) do
    loader = opts[:loader] || &Map.put/3
    schema = data.__meta__.schema
    { state, nil, nil }
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> create(data, opts[:data_type])
    |> Helpers.maybe_put_in_location(schema, opts[:strategy], opts[:location])
    |> Helpers.reload(schema, loader, opts[:strategy], opts[:location])
  end

  def create({ state, location_data, target }, data, data_type) do
    { state, location_data, create(target, data, data_type) }
  end
  def create(state, data, :list) do
    [ data | state ]
  end

  def get(_, _, _, opts), do: raise(RuntimeError, "State.Update failed to find a matching clause with options #{inspect(opts)}")

  def apply(_, _, opts), do: raise(RuntimeError, "State.Update.apply failed to find a matching clause with options #{inspect(opts)}")
end
