defmodule StateHandlers.Helpers do

  require Logger

  def maybe_access_assigns(%Phoenix.LiveView.Socket{} = socket) do
   #IO.puts("Accessing Assigns")
    [{socket.assigns, :assigns, :assigns}, {socket, nil, :socket}]
  end
  def maybe_access_assigns(state) do
   #IO.puts("Not accessing Assigns")
    [{state, nil, :state}]
  end

  def maybe_access_location(state, nil) do
   #IO.puts("Not accessing location")
    state
  end
  def maybe_access_location([{data, _, _} | _] = state, location) do
   #IO.puts("Accessing Location")
    case Map.get(data, location, nil) do
      nil -> raise(RuntimeError, "Access location failed because the location (#{location}) wasn't initialized properly  Available keys are #{inspect(Map.keys(data))}")
      location_data -> [{location_data, location, :location} | state]
    end
  end

  def maybe_access_type(nil, _, _), do: raise(RuntimeError, "maybe_access_type got nil data from location")
  def maybe_access_type(state, :by_item, _), do: state
  def maybe_access_type(state, :by_key, _), do: state
  def maybe_access_type(state, nil, schema), do: access_type(state, schema)
  def maybe_access_type(state, :by_type, schema), do: access_type(state, schema)

  def access_type([{data, _key, _type} | _] = state, schema) do
    case Map.get(data, type(schema)) do
      nil -> raise(RuntimeError, "access_type failed because it retreived a nil value from #{type(schema)}.  Available keys are #{inspect(Map.keys(data))}")
      result -> [{result, type(schema), :type} | state]
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

  def unpack_state([{data, _, _} | _]), do: data

  def maybe_put_in_type([{data, key, :type}, {type_data, next_key, next_type} | breadcrumb], :by_type) do
    #IO.puts("Putting in by Type")
    [{Map.put(type_data, key, data), next_key, next_type} | breadcrumb]
  end
  def maybe_put_in_type(state, _) do
    #IO.puts("Not Putting in by Type")
    state
  end

  def maybe_put_in_location([{data, location_key, :location}, {next_data, next_key, next_type}], _location) do
    #IO.puts("Putting in with location")
    [{Map.put(next_data, location_key, data), next_key, next_type}]
  end
  def maybe_put_in_location([{data, location_key, :location}, {next_data, next_key, next_type} | breadcrumb], _location) do
    #IO.puts("Putting in with location")
    [{Map.put(next_data, location_key, data), next_key, next_type} | breadcrumb]
  end
  def maybe_put_in_location(state, nil) do
    #IO.puts("Putting in without location")
    state
  end

  def socket_or_state([
      {assigns, :assigns, :assigns},
      {%Phoenix.LiveView.Socket{} = socket, nil, :socket} |
      _
 ], loader) do
    assigns = Map.delete(assigns, :flash)
    Enum.reduce(assigns, socket,
      fn({k, v}, socket) ->
        loader.(socket, k, v)
      end
    )
  end
  def socket_or_state([{state, _, :state}], _loader) do
    #IO.puts("It's the state")
    state
  end

  def reload({state, data, nil, nil}, schema, loader, :by_type, nil) do
    ##IO.puts("maybe_put_in_state by type without location")
    loader.(state, type(schema), data)
  end
  def reload({ state, location_data, nil, nil}, _schema, loader, :by_type, location) do
    ##IO.puts("maybe_put_in_state by type with location #{location}")
    loader.(state, location, location_data)
  end
end
