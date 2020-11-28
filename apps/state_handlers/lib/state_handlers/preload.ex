defmodule StateHandlers.Preload do

  def apply(state, data, preloads, opts) when is_list(data) do
    # IO.puts("Apply Preloads List to #{inspect(preloads)}")
    Enum.map(data, fn(d) -> apply(state, d, preloads, opts) end)
  end

  def apply(state, data, preloads, opts) when is_struct(data) do
    # IO.puts("Apply Preloads Struct to #{inspect(preloads)}")
    handle_preload(state, data, preloads, opts)
  end

  def apply(_state, nil, _preloads, _opts) do
    raise(RuntimeError, "State.Preload called with nil data")
  end
  def apply(_state, data, _preloads, _opts) do
    raise(RuntimeError, "State.Preload failed to find a matching clause")
  end

  defp handle_preload(state, data, preloads, opts) when is_list(preloads) do
    # IO.puts("handle_preload List #{inspect(preloads)}")
    Enum.reduce(preloads, data, fn(preload, d) -> handle_preload(state, d, preload, opts) end)
  end

  @moduledoc """
    This function handles preloads.  I used different type for different phases of the preload:

    atom:  This typically means that We're "at the end" and are loading the data from the state.

    tuple: This means there's a nested preload so we just call the original preload function and
    apply the preloads to the data.
  """
  defp handle_preload(state, data, preload, opts) when is_atom(preload) do
    # IO.puts("handle_preload Atom #{inspect(preload)}")
    schema = data.__meta__.schema
    preload_data = handle_assoc(state, data, schema.__schema__(:association, preload), opts)
    Map.put(data, preload, preload_data)
  end
  defp handle_preload(state, data, { key, value } = preload, opts) when is_tuple(preload) do
    # IO.puts("handle_preload tuple, #{inspect(key)}, #{inspect(value)}")
    data_to_preload = Map.get(data, key)
    preloads = value
    Map.put(data, key, apply(state, data_to_preload, preloads, opts))
  end

  defp handle_assoc(state, source, association, opts) do
    case association do
      %Ecto.Association.ManyToMany{} -> preload_many_to_many(state, association, source, opts)
      %Ecto.Association.BelongsTo{} ->
        case association.cardinality do
          :one -> preload_belongs_to_one(state, source, association, opts)
          _ -> raise("Cardinality not implemented")
        end
      %Ecto.Association.Has{} ->
        case association.cardinality do
          :many -> preload_has_many(state, source, association, opts)
          _ -> raise("Cardinality not implemented")
        end
      association_type -> raise("Association type #{inspect(association_type)} not implemented")
    end
  end

  defp preload_belongs_to_one(state, source, association, opts) do
    state
    |> StateHandlers.get(Map.get(source, association.owner_key), association.queryable, opts)
  end

  defp preload_has_many(state, source, association, opts) do
    # IO.puts("preload_has_many")
    owner = schema_atom(association.owner)
    owner_key = association.queryable.__schema__(:association, owner).owner_key

    state
    |> StateHandlers.list(association.queryable, opts)
    |> Enum.filter(fn(o) -> Map.get(o, owner_key) == source.id end)
  end

  defp preload_many_to_many(state, association, source, opts) do
    owner = schema_atom(association.owner)
    owner_key = association.join_through.__schema__(:association, owner).owner_key

    queryable = schema_atom(association.queryable)
    queryable_key = association.join_through.__schema__(:association, queryable).owner_key

    # IO.puts("Handling Many to Many Association.  Owner is #{owner}.  Joining through #{}.  Queryable is #{queryable}")
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
