defmodule StateHandlers.Helpers do

  require Logger

  def maybe_access_assigns({ state, nil, nil }) do
    #IO.puts("maybe_access_assigns state, nil, nil")
    { maybe_access_assigns(state), nil, nil }
  end
  def maybe_access_assigns(%Phoenix.LiveView.Socket{} = state), do: state.assigns
  def maybe_access_assigns(state), do: state

  def maybe_access_location({ state, nil, nil }, location) do
    #IO.puts("maybe_access_location state, nil, nil")
    { state, maybe_access_location(state, location), nil }
  end
  def maybe_access_location(state, nil) do
    #IO.puts("Not accessing location")
    state
  end
  def maybe_access_location(state, location) do
    #IO.puts("Accessing Location")
    Map.get(state, location, nil)
  end

  def maybe_access_type({ state, nil, nil}, strategy, schema) do
    #IO.puts("maybe_access_type state, nil, nil")
    { state, nil, maybe_access_type(state, strategy, schema) }
  end
  def maybe_access_type({ state, location_data, nil}, strategy, schema) do
    #IO.puts("maybe_access_type state, location_data, nil")
    { state, location_data, maybe_access_type(location_data, strategy, schema) }
  end
  def maybe_access_type(nil, _, _), do: raise(RuntimeError, "maybe_access_type got nil data from location")
  def maybe_access_type(state, :by_item, _), do: state
  def maybe_access_type(state, :by_key, _), do: state
  def maybe_access_type(state, nil, schema), do: access_type(state, schema)
  def maybe_access_type(state, :by_type, schema), do: access_type(state, schema)

  def access_type(state, schema) do
    #IO.inspect("access_type")
    case Map.get(state, type(schema)) do
      nil -> raise(RuntimeError, "access_type failed because it retreived a nil value from #{type(schema)}")
      result -> result
    end
  end

  def type(schema) do
    schema.__schema__(:source) |> String.to_atom()
  end

  def id_key(object) do
    type_from_struct(object)
    <> "_"
    <> Integer.to_string(object.id)
  end
  def id_key(type, id) do
    type
    <> "_"
    <> Integer.to_string(id)
  end

  def type_from_struct(object) do
    object.__meta__.schema
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.at(-1)
    |> String.downcase()
  end

  def maybe_put_in_location({ state, _location_data, data }, _schema, :by_type, nil) do
    # IO.puts("Putting in by Type without location")
    { state, data, nil }
  end
  def maybe_put_in_location({ state, location_data, data }, schema, :by_type, _location) do
    # IO.puts("Putting in by Type with location")
    { state, Map.put(location_data, type(schema), data), nil }
  end

  def reload({ state, nil, data}, schema, loader, :by_type, nil) do
    # IO.puts("Reload with no location")
    loader.(state, type(schema), data)
  end
  def reload({ state, data, nil }, schema, loader, :by_type, nil) do
    # IO.puts("Reload by type without location")
    loader.(state, type(schema), data)
  end
  def reload({ state, location_data, nil }, _schema, loader, :by_type, location) do
    # IO.puts("Reload by type with location #{location}")
    loader.(state, location, location_data)
  end
end
