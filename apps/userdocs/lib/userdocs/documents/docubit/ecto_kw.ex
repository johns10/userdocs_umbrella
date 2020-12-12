"""
defmodule EctoKW do
  use Ecto.Type
  def type, do: :jsonb

  # Provide custom casting rules.
  # Cast strings into the URI struct to be used at runtime

  def cast(kw = { key, value }) when is_atom(key) and is_atom(value)  do
    { :ok, Map.put(%{}, Atom.to_string(key), Atom.to_string(value)) }
  end

  def cast(kw = { key, value }) when is_atom(key)  do
    IO.puts("Casting Ecto KW")
    { :ok, kw }
  end

  # Loading data from the database
  def load(kw) when is_map(kw) do
    IO.puts("Loading KW")
    key = Map.keys(kw) |> Enum.at(0)
    value = Map.get(kw, key)
    { String.to_existing_atom(key), String.to_existing_atom(value) }
  end
  def load(kw) do
    IO.puts("Loading KW")
    kw
  end

  # dumping data to the database
  def dump({ key, value}) when is_atom(key) and is_atom(value) do
    IO.inspect("Dumping ectokw")
    { :ok, %{ Atom.to_string(key) => Atom.to_string(value) }}
  end
  def dump(kw = { _, _ }) do
    IO.inspect("Not Dumping ectokw")
    {:ok, kw}
  end
  def dump(_) do
    IO.inspect("Dumping ERROR")
    :error
  end
end
"""
