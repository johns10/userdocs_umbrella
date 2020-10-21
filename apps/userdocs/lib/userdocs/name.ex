defmodule UserDocs.Name do

  require Logger

  def field(name, string, seperator) do
    name <> string <> seperator
  end

  def maybe_field(name, object, key, seperator) do
    safe_value =
      retreive_value(object, key)
      |> safe_string()

    field(name, safe_value, seperator)
  end

  def retreive_value(object, key) when is_atom(key) do
    try do
      Map.get(object, key)
    rescue
      e ->
        Logger.error("#{inspect(e)}: Failed to retreive #{key} from step")
        ""
    end
  end

  def retreive_value(object, path) when is_list(path) do
    try do
      Enum.reduce(path, object, fn(k, o) -> Map.get(o, k) end)
    rescue
      e->
        Logger.error("#{inspect(e)}: Failed to retreive #{inspect(path)} from step")
        ""
    end
  end

  def safe_string(value) when is_integer(value), do: Integer.to_string(value)
  def safe_string(nil), do: "None"
  def safe_string(value), do: value
end
