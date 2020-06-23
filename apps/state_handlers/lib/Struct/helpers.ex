defmodule StateHandlers.StructHelpers do

  ################### Generic #########################
  def put_objects_on_state({ state, objects }, type) do
    Map.put(state, type, objects)
  end

  ################### Create ##########################
  def create_object({ objects, state }, object ) do
    { state, [ object | objects ] }
  end

  ################### Get #############################

  def get_data_type({ state }, type ) do
    { state, Map.fetch!(state, type) }
  end

  def get_by_ids({ state, data }, [] ) do
    #IO.puts("Passing get by ids")
    { state, data }
  end
  def get_by_ids({ state, data }, [ id | [] ] ) do
    #IO.puts("Filtering by single item list of ID's")
    { state, Enum.filter(data, fn(x) -> x.id == id end) }
  end
  def get_by_ids({ state, data }, ids = [ id | tail ] ) do
    #IO.puts("Filtering by list of ID's")
    { state, Enum.filter(data, fn(x) -> x.id in ids end) }
  end
  def get_by_ids({ state, data }, id ) do
    #IO.puts("Filtering by a single ID")
    response = Enum.filter(data, fn(x) -> x.id == id end)
    |> Enum.at(0)
    { state, response }
  end

  def get_from_data({ state, ids }, type ) do
    StateHandlers.get(state, type, ids)
  end

  def filter_to_data({ state, ids }, from_type, to_type ) do
    { state, data } = StateHandlers.get(state, to_type, [])
    { state, Enum.filter(data, fn(o) -> Map.fetch!(o, from_type) in ids end ) }

  end

  def map_object_ids({ state, data }) do
    { state, Enum.map(data, fn(o) -> o.id end) }
  end


  ##################### Update #########################
  #TODO: This creates non-existent keys.  Should raise Keyerror
  def update_object({ objects, state }, updated_object) do
    #IO.puts("Updating Object")
    target = Enum.find(
      objects,
      nil,
      fn(object) -> object.id == updated_object.id end
    )
    { state, [ updated_object | List.delete(objects, target) ] }
  end

  ##################### Delete #########################
  def delete_object({ objects, state }, object) do
    { state, List.delete(objects, object) }
  end

end
