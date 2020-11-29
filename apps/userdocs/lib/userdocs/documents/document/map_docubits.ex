defmodule UserDocs.Documents.Document.MapDocubits do

  alias UserDocs.Documents.DocumentVersion

  def apply(%DocumentVersion{ docubits: docubits }) do
    docubits
    |> Enum.sort(fn(i1, i2) -> i2.id > i1.id end ) # Unsorted addresses won't work.  This may not be the right sorting method.  Might need to sort by count of address items.
    |> Enum.reduce(%{}, fn(d, m) -> add_address_item(m, d, d.address) end)
  end

  def add_to_map(map, docubit) do
    add_address_item(map, docubit, docubit.address)
  end

  # This is the end item, where we reach the end of the address and put the final item
  defp add_address_item(map, docubit, [ address_item | [] ]) do
    # IO.puts("At end of address #{inspect(address_item)} on map #{inspect(map)} with docubit #{docubit.id}")
    object = %{ docubit: %{ id: docubit.id, docubits: %{} } }
    case map do
      %{docubit: %{ docubits: _ }} -> Kernel.put_in(map, [ :docubit, :docubits, address_item ], object)
      %{} -> Map.put(map, address_item, object)
    end
  end
  defp add_address_item(map, docubit, [ address_item | address ]) do
    case Map.get(map, address_item, nil) do
      nil ->
        # We reached a dead end in the map and will put in a new item
        Map.put_new(map, address_item, add_address_item(%{}, docubit, address))
      taken_map ->
        # IO.puts("In the address with item #{address_item} and remaining #{inspect(address)}.  The taken map is #{inspect(taken_map)}")
        Kernel.put_in(map, [ address_item ], add_address_item(taken_map, docubit, address))
    end
  end
end
