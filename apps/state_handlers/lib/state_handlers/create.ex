defmodule StateHandlers.Create do

  alias StateHandlers.Helpers

  def apply(state, data, opts) when is_struct(data) do
    IO.puts("Creating an opbect")
    loader = opts[:loader] || &Map.put/3
    schema = data.__meta__.schema
    state
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> create(data, opts[:data_type])
    |> Helpers.maybe_put_in_type(opts[:strategy])
    |> Helpers.maybe_put_in_location(opts[:location])
    |> Helpers.socket_or_state(loader)
  end
  def apply(_, _, opts) do
    raise(RuntimeError, "State.Update.apply failed to find a matching clause with options #{inspect(opts)}")
  end
  def create([ { state, key, state_type } | breadcrumb ], data, data_type) do
    IO.puts("create state parser")
    [ { create(state, data, data_type), key, state_type} | breadcrumb ]
  end
  def create(state, data, :list) do
    [ data | state ]
  end
end
