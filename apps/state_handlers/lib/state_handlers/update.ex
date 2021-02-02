defmodule StateHandlers.Update do

  alias StateHandlers.Helpers

  def do_update(state, data, opts) when is_struct(data) do
    do_update(state, data, data.__meta__.schema, opts)
  end
  def do_update(state, %{ objects: [ _ | _ ]} = data, opts)  do
    schema =
      data.objects
        |> Enum.at(0)
        |> Map.get(:__meta__)
        |> Map.get(:schema)

    do_update(state, data, schema, opts)
  end
  def do_update(state, %{ objects: []}, opts) do
    raise(RuntimeError, "Objects empty")
  end
  def do_update(state, data, schema, opts) do
    #IO.puts("Updating an obect with opts #{inspect(opts)}")
    loader = opts[:loader] || &Map.put/3
    state
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> update(data, opts[:data_type])
    |> Helpers.maybe_put_in_type(opts[:strategy])
    |> Helpers.maybe_put_in_location(opts[:location])
    |> Helpers.socket_or_state(loader)
  end

  def update([ { state, key, state_type } | breadcrumb ], data, data_type) do
    [ { update(state, data, data_type), key, state_type} | breadcrumb ]
  end
  def update(state, %{ objects: data }, :list) when is_list(data) do
    Enum.reduce(data, state,
      fn(object, acc) ->
        update(acc, object, :list)
      end
    )
  end
  def update(state, object, :list) when is_struct(object) do
    Enum.map(state,
      fn(o) ->
        case o.id == object.id do
          true -> object
          false -> o
        end
      end
    )
  end

  #def do_update(_, _, _, opts), do: raise(RuntimeError, "State.Update failed to find a matching clause with options #{inspect(opts)}")

  #def do_update(_, _, opts), do: raise(RuntimeError, "State.Update.apply failed to find a matching clause with options #{inspect(opts)}")
end
