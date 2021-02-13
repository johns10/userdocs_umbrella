defmodule StateHandlers.Delete do

  alias StateHandlers.Helpers

  def apply(state, data, opts) when is_struct(data) do
    IO.puts("Deleting an opbect")
    loader = opts[:loader] || &Map.put/3
    schema = data.__meta__.schema
    state
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> delete(data, opts[:data_type])
    |> Helpers.maybe_put_in_type(opts[:strategy])
    |> Helpers.maybe_put_in_location(opts[:location])
    |> Helpers.socket_or_state(loader)
  end
  def apply(_, _, opts), do: raise(RuntimeError, "State.Update.apply failed to find a matching clause with options #{inspect(opts)}")

  def delete([ { state, key, state_type } | breadcrumb ], data, data_type) do
    IO.puts("delete state parser")
    [ { delete(state, data, data_type), key, state_type} | breadcrumb ]
  end
  def delete(state, data, :list) do
    Enum.filter(state,
      fn(item) ->
        item.id != data.id
      end
    )
  end

  def get(_, _, _, opts), do: raise(RuntimeError, "State.Update failed to find a matching clause with options #{inspect(opts)}")

end
