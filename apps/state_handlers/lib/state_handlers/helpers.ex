defmodule StateHandlers.Helpers do

  def maybe_access_assigns(%Phoenix.LiveView.Socket{} = state), do: state.assigns
  def maybe_access_assigns(state), do: state

  def maybe_access_location(state, nil), do: state
  def maybe_access_location(state, location) do
    Map.get(state, location)
  end

  def maybe_access_type(state, :by_key, _), do: state
  def maybe_access_type(state, nil, schema), do: access_type(state, schema)
  def maybe_access_type(state, :by_type, schema), do: access_type(state, schema)

  def access_type(state, schema) do
    Map.get(state, type(schema))
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
end
