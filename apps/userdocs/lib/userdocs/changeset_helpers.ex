defmodule UserDocs.ChangesetHelpers do
  def check_only_one_default(%Ecto.Changeset{ action: :insert } = changeset, _) do
    changeset
  end
  def check_only_one_default(changeset, assoc_key) do
    num_defaults =
      case Ecto.Changeset.get_change(changeset, assoc_key) do
        nil -> count_defaults(Map.get(changeset.data, assoc_key))
        assoc -> count_defaults(assoc)
      end
    num_projects =
      Ecto.Changeset.get_field(changeset, :projects)
      |> count_projects()

    if num_defaults != 1 && num_projects > 0 do
      Ecto.Changeset.add_error(changeset, assoc_key, "May only have 1 default")
    else
      changeset
    end
  end

  def count_projects(nil), do: 0
  def count_projects([]), do: 0
  def count_projects([ _ ] = projects) do
    Enum.count(projects)
  end

  def count_defaults(%Ecto.Association.NotLoaded{}), do: 0
  def count_defaults([ %Ecto.Changeset{} | _ ] = assoc) do
    Enum.reduce(assoc, 0,
      fn(item, acc) ->
        case { Ecto.Changeset.get_change(item, :default, nil), item.data.default } do
          { true, _ } -> acc + 1
          { nil, true } -> acc + 1
          { _, _ } -> acc
        end
      end
    )
  end
  def count_defaults(data) do
    Enum.reduce(data, 0,
      fn(item, acc) ->
        case item.default do
          true -> acc + 1
          false -> acc
          nil -> acc
        end
      end
    )
  end

  def maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset
  def maybe_mark_for_deletion(changeset) do
    if Ecto.Changeset.get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end

  def add_object(changeset, object, key, fresh_changeset) do
    existing_objects =
      Map.get(changeset.changes, key,
        Map.get(object, key)
      )

    objects =
      existing_objects
      |> Enum.concat([ fresh_changeset ])

    changeset
    |> Ecto.Changeset.put_assoc(key, objects)
  end

  def remove_object(changeset, key, remove_id) do
    objects =
      Map.get(changeset.changes, key)
      |> Enum.reject(fn %{data: object} ->
        object.temp_id == remove_id
      end)

    changeset
    |> Ecto.Changeset.put_assoc(key, objects)
  end
end
