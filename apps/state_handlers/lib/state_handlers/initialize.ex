defmodule StateHandlers.Initialize do

  alias StateHandlers.Helpers

  def apply(state, opts) do
    loader = opts[:loader] || &Map.put/3
    state
    |> Helpers.maybe_access_assigns()
    |> maybe_create_location(opts[:location])
    |> maybe_create_types(opts[:strategy], opts[:types], opts[:data_type])
    |> Helpers.maybe_put_in_location(opts[:location])
    |> Helpers.socket_or_state(loader)
    |> IO.inspect()
  end

  def maybe_create_location(state, nil), do: state
  def maybe_create_location([{ _state, _key, _type } | _ ] = breadcrumb, location) do
    [ { %{}, location, :location } | breadcrumb ]
  end

  def maybe_create_types(state, nil, _, _), do: state
  def maybe_create_types(state, _, [], _), do: state
  def maybe_create_types(state, _, nil, _), do: state
  def maybe_create_types([{ data, key, type } | breadcrumb ], strategy, types, data_type) do
    [ { maybe_create_types(data, strategy, types, data_type), key, type } | breadcrumb ]
  end
  def maybe_create_types(state, :by_type, types, :list), do: create_types(state, types, [])
  def maybe_create_types(state, :by_type, types, :map), do: create_types(state, types, %{})
  def maybe_create_types(state, :by_type, types, _), do: create_types(state, types, %{})

  def create_types(state, types, initial) do
    Enum.reduce(types, state,
      fn(type, state) ->
        Map.put(state, Helpers.type(type), initial)
      end
    )
  end

end
