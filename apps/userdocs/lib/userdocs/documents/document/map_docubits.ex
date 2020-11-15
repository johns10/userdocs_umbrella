defmodule UserDocs.Documents.Document.MapDocubits do

  alias UserDocs.Documents.Document

  def apply(%Document{ docubits: docubits }) do
    Enum.reduce(docubits, %{},
      fn(d, m) -> add_address_item(m, d, d.address) end)
  end

  defp add_address_item(map, docubit, [ address_item | [] ]) do
    # IO.puts("At end of address #{inspect(address_item)} on map #{inspect(map)}")
    Map.put(map, address_item, %{ id: docubit.id })
  end
  defp add_address_item(map, docubit, [ address_item | address ]) do
    case Map.get(map, address_item, nil) do
      nil ->
        Map.put_new(map, address_item, add_address_item(%{}, docubit, address))
      taken_map ->
        # IO.puts("In the address with item #{address_item} and remaining #{inspect(address)}.  The taken map is #{inspect(taken_map)}")
        Map.put(map, address_item, add_address_item(taken_map, docubit, address))
    end
  end
end
