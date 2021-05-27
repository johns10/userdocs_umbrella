defmodule StateHandlers.Preload do
  require Logger

  def apply(state, data, opts) do
    case opts[:preloads] do
      nil -> raise(RuntimeError, "Preloads not found in opts")
      preloads -> apply(state, data, preloads, Keyword.delete(opts, :preloads))
    end
  end
  def apply(state, data, preloads, opts) when is_list(data) do
    #IO.puts("Apply Preloads List to #{inspect(preloads)}")
    Enum.map(data, fn(d) -> apply(state, d, preloads, opts) end)
  end

  def apply(state, data, preloads, opts) when is_struct(data) do
    #IO.puts("Apply Preloads Struct to #{inspect(preloads)}")
    handle_preload(state, data, preloads, opts)
  end

  def apply(_state, nil, _preloads, _opts) do
    #Logger.error("State.Preload called with nil data")
    nil
  end
  def apply(_state, _data, _preloads, _opts) do
    raise(RuntimeError, "State.Preload failed to find a matching clause")
  end

  defp handle_preload(state, data, preloads, opts) when is_list(preloads) do
    #IO.puts("handle_preload List #{inspect(preloads)}")
    Enum.reduce(preloads, data, fn(preload, d) -> handle_preload(state, d, preload, opts) end)
  end

  @moduledoc """
    This function handles preloads.  I used different type for different phases of the preload:

    atom:  This typically means that We're "at the end" and are loading the data from the state.

    tuple: This means there's a nested preload so we just call the original preload function and
    apply the preloads to the data.
  """
  defp handle_preload(_state, nil, _preload, _opts), do: nil
  defp handle_preload(state, data, preload, opts) when is_atom(preload) do
    #IO.puts("handle_preload Atom #{inspect(preload)}")
    schema = data.__meta__.schema
    opts = prepare_preload_opts(opts, schema, preload)
    #IO.puts(opts[:order])
    preload_data = handle_assoc(state, data, schema.__schema__(:association, preload), opts)
    Map.put(data, preload, preload_data)
  end
  defp handle_preload(state, data, { key, value } = preload, opts) when is_tuple(preload) do
    #IO.puts("handle_preload tuple, #{inspect(key)}, #{inspect(value)}")
    data_to_preload = Map.get(data, key)
    preloads = value
    opts =
      case data_to_preload do
        nil -> opts
        [] -> opts
        [ object | _ ] ->
          prepare_preload_opts(opts, object.__meta__.schema, preload)
        object ->
          prepare_preload_opts(opts, object.__meta__.schema, preload)
      end
    Map.put(data, key, apply(state, data_to_preload, preloads, opts))
  end

  defp prepare_preload_opts(opts, schema, preload) do
    #IO.puts("preparing preload opts for #{schema}")
    opts
    |> prepare_order_clause(opts[:order], schema.__schema__(:associations), preload)
    |> prepare_limit_clause(opts[:limit], schema.__schema__(:associations), preload)
  end

  defp prepare_limit_clause(opts, nil, _, _), do: opts
  defp prepare_limit_clause(opts, limit_clause, fields, preload) do
    #IO.puts("Preparing limit clause ")
    updated_limit_clause =
      Enum.reduce(limit_clause, [],
        fn(limit_opt, inner_opts) ->
          handle_limit_option(inner_opts, limit_opt, fields, preload)
        end
      )
    Keyword.put(opts, :limit, updated_limit_clause)
  end

  defp prepare_order_clause(opts, nil, _, _), do: opts
  defp prepare_order_clause(opts, order_clause, fields, preload) do
    #IO.puts("Preparing order clause ")
    updated_order_clause =
      Enum.reduce(order_clause, [],
        fn(order_opt, inner_opts) ->
          handle_order_option(inner_opts, order_opt, fields, preload)
        end
      )
    Keyword.put(opts, :order, updated_order_clause)
  end

  def handle_order_option(order_opts, %{field: _, order: _}, _fields, _preload) do
    #IO.puts("Rejecting order option")
    order_opts
  end
  def handle_order_option(order_opts, {association, %{ field: _, order: _ } = order_opt}, associations, preload) do
    #IO.puts("handle_order_option")
    case (association in associations) and association == preload do
      true -> [ order_opt | order_opts ]
      false ->
        #Logger.warn("handle_order_option was passed an invalid association: #{association}, or it didn't match the preload: #{preload}.  Available associations are #{inspect(associations)}")
        order_opts
    end
  end
  def handle_order_option(order_opts, {_association, [ _ ] = order_opt}, _associations, _preload) do
    #IO.puts("Handling Order Option for a deeply nested order call: #{association}, #{inspect(order_opt)}")
    order_opts ++ order_opt
  end
  def handle_order_option(order_opts, {_association, order_opt}, _associations, _preload) do
    #IO.puts("Handling Order Option for a nested order call: #{association}: #{inspect(order_opt)}")
    [ order_opt | order_opts ]
  end
  def handle_order_option([], _, _, _), do: []

  def handle_limit_option(limit_opts, limit, _fields, _preload) when is_number(limit) do
    #IO.puts("Rejecting limit option")
    limit_opts
  end
  def handle_limit_option(limit_opts, {association, limit_opt}, associations, preload) when is_number(limit_opt) do
    #IO.puts("handle_limit_option")
    case (association in associations) and association == preload do
      true -> [ limit_opt | limit_opts ]
      false ->
        # Logger.warn("handle_limit_option was passed an invalid association: #{association}, or it didn't match the preload: #{inspect(preload)}.  Available associations are #{inspect(associations)}")
        limit_opts
    end
  end
  def handle_limit_option(limit_opts, {association, [ _ ] = limit_opt}, _associations, _preload) do
    #IO.puts("Handling Limit Option for a deeply nested limit call: #{association}, #{inspect(limit_opt)}.  The current opts are #{inspect(limit_opts)}.")
    limit_opts ++ limit_opt
  end
  def handle_limit_option(limit_opts, {association, limit_opt}, _associations, _preload) do
    #IO.puts("Handling Limit Option for a nested limit call: #{association}: #{inspect(limit_opt)}")
    [ limit_opt | limit_opts ]
  end
  def handle_limit_option([], _, _, _), do: []

  defp handle_assoc(state, source, association, opts) do
    case association do
      %Ecto.Association.ManyToMany{} -> preload_many_to_many(state, association, source, opts)
      %Ecto.Association.BelongsTo{} ->
        case association.cardinality do
          :one -> preload_belongs_to_one(state, source, association, opts)
          cardinality -> raise("Cardinality #{cardinality} not implemented")
        end
      %Ecto.Association.Has{} ->
        case association.cardinality do
          :many -> preload_has_many(state, source, association, opts)
          :one -> preload_has_one(state, source, association, opts)
          cardinality -> raise("Cardinality #{cardinality} not implemented")
        end
      association_type -> raise("Association type #{inspect(association_type)} not implemented")
    end
  end

  defp preload_belongs_to_one(state, source, association, opts) do
    state
    |> StateHandlers.get(Map.get(source, association.owner_key), association.queryable, opts)
  end

  defp preload_has_many(state, source, association, opts) do
    owner = schema_atom(association.owner)
    owner_key = association.queryable.__schema__(:association, owner).owner_key

    _log_string = """
      Preloading has_many from owner: #{inspect(association.owner)} to child: #{inspect(association.queryable)}.
      We'll query on owner key #{owner_key}, with value #{source.id}
    """

    state
    |> StateHandlers.list(association.queryable, opts)
    |> Enum.filter(fn(o) -> Map.get(o, owner_key) == source.id end)
    |> maybe_limit(opts[:limit])
  end

  def maybe_limit(data, [ limit ] ) do
    Enum.take(data, limit)
  end
  def maybe_limit(data, _limit), do: data

  defp preload_has_one(state, source, association, opts) do
    # should be similar to has many
    owner = schema_atom(association.owner)
    owner_key = association.queryable.__schema__(:association, owner).owner_key

    state
    |> StateHandlers.list(association.queryable, opts)
    |> Enum.filter(
      fn(o) ->
        Map.get(o, owner_key) == source.id
      end)
    |> Enum.at(0)
  end

  defp preload_many_to_many(state, association, source, opts) do
    owner = schema_atom(association.owner)
    owner_key = association.join_through.__schema__(:association, owner).owner_key

    queryable = schema_atom(association.queryable)
    queryable_key = association.join_through.__schema__(:association, queryable).owner_key

    #IO.puts("Handling Many to Many Association.  Owner is #{owner}.  Joining through #{}.  Queryable is #{queryable}")
    join_opts = Keyword.put(opts, :filter, { owner_key, source.id })

    queryable_ids =
      state
      |> StateHandlers.list(association.join_through, join_opts)
      |> Enum.map(fn(o) -> Map.get(o, queryable_key) end)

    join_opts = Keyword.put(opts, :ids, queryable_ids)

    StateHandlers.list(state, association.queryable, join_opts)
  end

  defp schema_atom(schema_name) do
    schema_name
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.at(-1)
    |> Macro.underscore()
    |> String.to_atom()
  end
end
