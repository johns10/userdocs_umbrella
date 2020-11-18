defmodule State.Helpers do
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
end
