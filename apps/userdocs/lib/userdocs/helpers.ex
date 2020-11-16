defmodule UserDocs.Helpers do
  def select_list(items, field, true) do
    select_list(items, field, false)
    |> List.insert_at(0, {"None", ""})
  end
  def select_list(items, field, false) do
    items
    |> Enum.map(&{Map.get(&1, field), &1.id})
  end
end
