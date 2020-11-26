defmodule StateHandlers.List do

  alias StateHandlers.Helpers

  def apply(state, schema, opts) do
    log_string = "StateHandlers.List in location #{opts[:location]} on #{Helpers.type(schema)} with opts #{inspect(opts)}"
    if opts[:debug], do: IO.puts(log_string)
    state
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> maybe_filter_by_ids(opts[:ids], opts[:data_type])
    |> maybe_filter_by_field(opts[:filter], opts[:data_type])
    |> cast_by_type(opts[:data_type])
  end

  defp maybe_filter_by_ids(nil, _, _), do: raise(RuntimeError, "StateHandlers.List data is nil")
  defp maybe_filter_by_ids(data, nil, _), do: data
  defp maybe_filter_by_ids(data, ids, :map), do: filter_map_by_ids(data, ids)
  defp maybe_filter_by_ids(data, ids, :list), do: filter_list_by_ids(data, ids)
  defp maybe_filter_by_ids(data, ids, nil), do: filter_list_by_ids(data, ids)

  def filter_map_by_ids(data, ids), do: Map.take(data, ids)
  def filter_list_by_ids(data, ids), do: Enum.filter(data, fn(d) -> d.id in ids end)

  defp maybe_filter_by_field(data, nil, _), do: data
  defp maybe_filter_by_field(data, { field, value }, nil), do: filter_list_by_field(data, { field, value})
  defp maybe_filter_by_field(data, { field, value }, :map), do: filter_map_by_field(data, { field, value})
  defp maybe_filter_by_field(data, { field, value }, :list), do: filter_list_by_field(data, { field, value})

  def filter_map_by_field(data, { field, value}) do
    Enum.filter(data, fn({_, o}) -> Map.get(o, field) == value end)
  end

  def filter_list_by_field(data, { field, value}) do
    Enum.filter(data, fn(d) -> Map.get(d, field) == value end)
  end

  def cast_by_type(data, :list), do: data
  def cast_by_type(data, nil), do: data
  def cast_by_type(data, :map), do: Enum.map(data, fn({_, v}) -> v end)

  def apply(_, _, _), do: raise(RuntimeError, "State.Get failed to find a matching clause")
end
