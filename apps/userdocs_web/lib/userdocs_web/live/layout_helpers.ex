defmodule UserDocsWeb.Layout do
  use Phoenix.HTML

  def is_hidden?(%{expanded: false}), do: " is-hidden"
  def is_hidden?(%{expanded: true}), do: ""
  def is_hidden?(%{action: :new}), do: ""
  def is_hidden?(%{action: :show}), do: " is-hidden"
  def is_hidden?(false, :new), do: ""
  def is_hidden?(_, _), do: " is-hidden"


  def form_field_id(action, f, field, parent_type, parent_id) do
    parent_type <> "_"
    <> Integer.to_string(parent_id) <> "_"
    <> field_name(f)
    <> id_or_new(action, f) <> "_"
    <> Atom.to_string(field)
  end

  defp field_name(f) do
    f.data.__meta__.schema
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.reverse()
    |> Enum.at(0)
    |> String.downcase(:default)
  end

  defp id_or_new(:edit, f), do: "_" <> Integer.to_string(f.data.id)
  defp id_or_new(:new, f), do: "_new"
end
