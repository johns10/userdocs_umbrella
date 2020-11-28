defmodule UserDocs.Helpers do
  def select_list(items, field, true) do
    select_list(items, field, false)
    |> List.insert_at(0, {"None", ""})
  end
  def select_list(items, field, false) do
    items
    |> Enum.map(&{Map.get(&1, field), &1.id})
  end

  def validate_params(params, required_keys, module) do
    case Enum.all?(required_keys, &Map.has_key?(params, &1)) do
      true -> params
      false -> raise("#{inspect(module)} doesn't have all required keys.  Missing #{inspect(required_keys -- Map.keys(params))}")
    end
  end
end
