defmodule StateHandlers.Struct do

  alias StateHandlers.StructHelpers

  def get(state, type, ids \\ []) do
    #IO.puts("Getting Data of type #{type} with ids:")
    StructHelpers.get_data_type({ state }, type)
    |> StructHelpers.get_by_ids(ids)
  end

  @doc """
  Takes a list of objects, and a type of relationship.  Makes a list of the
  related ids, by the given type, and queries the state for the ID's in that
  list.
  Used to get all the objects related in a single shot.
  """
  def get_related(state, from_type, from_data, to_type) do
    #IO.puts("Getting Related Data")
    { state, from_data }
    |> StructHelpers.map_object_ids()
    |> StructHelpers.filter_to_data(from_type, to_type)
  end

  def create(state, type, object) do
    state
    |> Map.pop(String.to_atom(type))
    |> StructHelpers.create_object(object)
    |> StructHelpers.put_objects_on_state(type)
    |> get(type, [ object.id ])
  end

  def update(state, type, object) do
    #IO.puts("Updating #{type} -> #{id}")
    state
    |> Map.pop(type)
    |> StructHelpers.update_object(object)
    |> StructHelpers.put_objects_on_state(type)
    |> get(type, [ object.id ])
  end

  def delete(state, type, id) do
    #IO.puts("Deleting #{type} -> id")
    state
    |> Map.pop(type)
    |> StructHelpers.delete_object(id)
    |> StructHelpers.put_objects_on_state(type)
  end

end
