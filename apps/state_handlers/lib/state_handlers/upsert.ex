defmodule StateHandlers.Upsert do

  alias StateHandlers.Helpers

  def do_upsert(state, data, opts) when is_struct(data) do
    do_upsert(state, data, data.__meta__.schema, opts)
  end
  def do_upsert(state, %{ objects: [ _ | _ ]} = data, opts)  do
    schema =
      data.objects
        |> Enum.at(0)
        |> Map.get(:__meta__)
        |> Map.get(:schema)

        do_upsert(state, data, schema, opts)
  end
  def do_upsert(_state, %{ objects: []}, _opts) do
    raise(RuntimeError, "Objects empty")
  end
  def do_upsert(state, data, schema, opts) do
    #IO.puts("Updating an obect with opts #{inspect(opts)}")
    loader = opts[:loader] || &Map.put/3
    state
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> upsert(data, opts[:data_type])
    |> Helpers.maybe_put_in_type(opts[:strategy])
    |> Helpers.maybe_put_in_location(opts[:location])
    |> Helpers.socket_or_state(loader)
  end

  def upsert([ { state, key, state_type } | breadcrumb ], data, data_type) do
    [ { upsert(state, data, data_type), key, state_type} | breadcrumb ]
  end
  def upsert(state, %{ objects: data }, :list) when is_list(data) do
    Enum.reduce(data, state,
      fn(object, acc) ->
        upsert(acc, object, :list)
      end
    )
  end
  def upsert(state, object, :list) when is_struct(object) do
    case object.id in ids(state, :list) do
      true -> StateHandlers.Update.update(state, object, :list)
      false -> StateHandlers.Create.create(state, object, :list)
    end
  end

  def ids(state, :list) do
    Enum.map(state, fn(object) -> object.id end)
  end
end
