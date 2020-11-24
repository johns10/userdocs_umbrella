defmodule StateHandlers.Helpers do

  require Logger

  def maybe_access_assigns(%Phoenix.LiveView.Socket{} = state), do: state.assigns
  def maybe_access_assigns(state), do: state

  def maybe_access_location(state, nil), do: state
  def maybe_access_location(state, location) do
    Map.get(state, location)
  end

  def maybe_access_type(nil, _, schema), do: raise(RuntimeError, "maybe_access_type got nil data from location")
  def maybe_access_type(state, :by_item, _), do: state
  def maybe_access_type(state, :by_key, _), do: state
  def maybe_access_type(state, nil, schema), do: access_type(state, schema)
  def maybe_access_type(state, :by_type, schema), do: access_type(state, schema)

  def access_type(state, schema) do
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

  def reassign(state, _location_data, data, %{ schema: schema, location: nil, loader: loader }) do
    loader.(state, type(schema), data)
  end
  def reassign(state, _location_data, data, %{ schema: schema, location: nil, loader: nil }) do
    Map.put(state, type(schema), data)
  end
  def reassign(state, location_data, data, %{ schema: schema, location: location, loader: loader })
  when is_atom(location) do
    location_data = Map.put(location_data, type(schema), data)
    loader.(state, location, location_data)
  end
  def reassign(state, location_data, data, %{ schema: schema, location: location, loader: nil })
  when is_atom(location) do
    location_data = Map.put(location_data, type(schema), data)
    Map.put(state, location, location_data)
  end
end
