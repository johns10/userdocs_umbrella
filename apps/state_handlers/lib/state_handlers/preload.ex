defmodule StateHandlers.Preload do

  def apply(state, data, preloads, opts) when is_list(data) do
    # IO.puts("Apply Preloads List to #{inspect(preloads)}")
    Enum.map(data, fn(d) -> apply(state, d, preloads, opts) end)
  end

  def apply(state, data, preloads, opts) when is_struct(data) do
    # IO.puts("Apply Preloads Struct to #{inspect(preloads)}")
    handle_preload(state, data, preloads, opts)
  end

  defp handle_preload(state, data, preloads, opts) when is_list(preloads) do
    # IO.puts("handle_preload List #{inspect(preloads)}")
    Enum.reduce(preloads, data, fn(preload, d) -> handle_preload(state, d, preload, opts) end)
  end

  @moduledoc """
    This function handles preloads.  I used different type for different phases of the preload:

    atom:  This typically means that We're "at the end" and are loading the data from the state.

    tuple: This means there's a nested preloa so we just call the original preload function and
    apply the preloads to the data.
  """
  defp handle_preload(state, data, preload, opts) when is_atom(preload) do
    # IO.puts("handle_preload Atom #{inspect(preload)}")
    schema = data.__meta__.schema
    preload_data = handle_assoc(state, data.id, schema.__schema__(:association, preload), opts)
    Map.put(data, preload, preload_data)
  end
  defp handle_preload(state, data, { key, value } = preload, opts) when is_tuple(preload) do
    data_to_preload = Map.get(data, key)
    preloads = value
    Map.put(data, key, apply(state, data_to_preload, preloads, opts))
  end

  defp handle_assoc(state, source_id, association, opts) do
    case association do
      %Ecto.Association.ManyToMany{} -> preload_many_to_many(state, association, source_id, opts)
      %Ecto.Association.Has{} ->
        case association.cardinality do
          :many -> preload_has_many(state, source_id, association)
          _ -> raise("Cardinality not implemented")
        end
      _ -> raise("This association type not implemented")
    end
  end

  defp preload_has_many(state, source_id, association) do
    owner = schema_atom(association.owner)
    queryable_source = association.queryable.__schema__(:source) |> String.to_atom()
    owner_key = association.queryable.__schema__(:association, owner).owner_key

    state
    |> Map.get(queryable_source)
    |> Enum.filter(fn(o) -> Map.get(o, owner_key) == source_id end)
  end

  defp preload_many_to_many(state, association, source_id, opts) do
    owner = schema_atom(association.owner)
    owner_key = association.join_through.__schema__(:association, owner).owner_key

    queryable = schema_atom(association.queryable)
    queryable_key = association.join_through.__schema__(:association, queryable).owner_key

    # IO.puts("Handling Many to Many Association.  Owner is #{owner}.  Joining through #{join_source}.  Queryable is #{queryable}")
    join_opts = Keyword.put(opts, :filter, { owner_key, source_id })

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
    |> String.downcase()
    |> String.to_atom()
  end

  def apply(_, _, _), do: raise(RuntimeError, "State.Get failed to find a matching clause")
end
