defmodule StateHandlers.List do

  alias StateHandlers.Helpers

  def apply(state, schema, opts) do
    log_string = "StateHandlers.List in location #{opts[:location]} on #{Helpers.type(schema)} with opts #{inspect(opts)}"
    if opts[:debug], do: IO.puts(log_string)
    {filter, opts} = Keyword.pop(opts, :filter, nil)
    state
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.maybe_access_type(opts[:strategy], schema)
    |> Helpers.unpack_state()
    |> maybe_handle_order_clauses(opts[:order], opts[:data_type])
    |> maybe_filter_by_ids(opts[:ids], opts[:data_type])
    |> maybe_filter_by_field(filter, opts[:data_type])
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
  defp maybe_filter_by_field(data, {field, value}, nil), do: filter_list_by_field(data, {field, value})
  defp maybe_filter_by_field(data, {field, value}, :map), do: filter_map_by_field(data, {field, value})
  defp maybe_filter_by_field(data, {field, value}, :list), do: filter_list_by_field(data, {field, value})

  # Iterates over the existing order clauses and calls handle_order_clause on each,
  # if it's valid.  Passes if it's nil.  Should raise for an invalid order clause if
  # we don't get a list of order clauses

  defp maybe_handle_order_clauses(data, nil, _), do: data
  defp maybe_handle_order_clauses(data, [], _), do: data
  defp maybe_handle_order_clauses(data, [_ | _] = clauses, type) do
    Enum.reduce(clauses, data, fn(clause, data) -> handle_order_clause(data, clause, type) end)
  end
  defp maybe_handle_order_clauses(_, clauses, _), do: raise(RuntimeError, "maybe_handle_order_clauses was passed invalid order clauses: #{inspect(clauses)}")

  # Orders the data retreived from the state.  When there are no preloads, or nested
  # preloads, we pass, for example:

  #   maybe_order(data, nil, _)
  #   maybe_order(data, {document_versions : %{field: :id, order: :desc}})

  # When we pass with nested orders, they should get passed on the appropriate child in
  # preload.  If we pass in a order of the form %{field: _, order: _}, we should order
  # the data according to the args.

  # Only supports :asc and :desc, and assumes that elixir will do the right thing with
  # > and < for text.

  # When we have an orders clause, we'll iterate and apply each option, because we might
  # have multiple order clauses

  defp handle_order_clause(data, nil, _), do: data
  defp handle_order_clause(data, {_, %{}}, _), do: data
  defp handle_order_clause(data, {_, [_]}, _), do: data
  defp handle_order_clause(data, [_], _), do: data
  defp handle_order_clause(data, %{field: field, order: order}, :list) do
    #IO.puts("handle_order_clause")
    Enum.sort(data,
      fn(i1, i2) ->
        case order do
          :asc -> Map.get(i1, field) < Map.get(i2, field)
          :desc -> Map.get(i1, field) > Map.get(i2, field)
        end
      end
    )
  end

  def filter_map_by_field(data, {field, value}) do
    Enum.filter(data, fn({_, o}) -> Map.get(o, field) == value end)
  end

  def filter_list_by_field(data, {field, value}) do
    Enum.filter(data, fn(d) -> Map.get(d, field) == value end)
  end

  def cast_by_type(data, :list), do: data
  def cast_by_type(data, nil), do: data
  def cast_by_type(data, :map), do: Enum.map(data, fn({_, v}) -> v end)
end
