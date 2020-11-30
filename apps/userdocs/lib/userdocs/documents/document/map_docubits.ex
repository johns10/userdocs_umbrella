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

  # To add an address item, we'll put an object containing the docubit id, and an empty
  # Map to hold additional docubits at the address specified
  defp add_address_item(map, docubit, [ address_item | [] ]) do
    object = %{ docubit: %{ id: docubit.id, docubits: %{} } }
    # IO.puts("At end of address #{inspect(address_item)} on map #{inspect(map)} with docubit #{docubit.id}: #{inspect(object)}")
    Map.put(map, address_item, object)
  end
  # To add a nested address item, we'll put the address item, as defined above in the
  # Address location
  defp add_address_item(map, docubit, [ address_item | address ]) do
    location =
      case Kernel.get_in(map, [ address_item, :docubit, :docubits ]) do
        nil -> %{}
        map -> map
      end
    item = add_address_item(location, docubit, address)
    # IO.puts("In the address with item #{address_item} and remaining #{inspect(address)}.  We'll put the docubit in #{inspect(location)}")
    Kernel.put_in(map, [ address_item, :docubit, :docubits ], item)
  end
end
