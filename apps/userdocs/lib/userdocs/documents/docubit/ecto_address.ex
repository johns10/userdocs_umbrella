defmodule EctoAddress do
  use Ecto.Type
  def type, do: :map
  alias UserDocs.Documents.Docubit.Address

  def cast(address = %{ docubit_id: docubit_id, body: body }) when is_integer(docubit_id) and is_struct(body, Address) do
    IO.puts("Casting struct EctoAddress")
    #IO.inspect(address)
    { :ok, address }
  end
  def cast(address = %{ docubit_id: docubit_id, body: body }) when is_integer(docubit_id) and is_map(body) do
    IO.puts("Casting map EctoAddress")
    #IO.inspect(address)
    { :ok, %{ docubit_id: docubit_id, body: Kernel.struct(Address, body) } }
  end

  def load(kw), do: kw

  def dump(kw = { _, _ }), do: {:ok, kw}
  def dump(_), do: :error
end
