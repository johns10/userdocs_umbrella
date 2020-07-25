defmodule UserDocsWeb.DomainHelpers do

  def maybe_select_list(assigns, key) do
    select_list =
      try do
        Map.get(assigns.select_lists, key)
      rescue
        _ -> []
      end

    select_list(select_list)
  end

    @doc """

    """
    def select_list(items, field \\ :name)
    def select_list([], _), do: [{"None", ""}]
    def select_list(nil, _), do: [{"None", ""}]
    def select_list(items, field) do
      items
      |> Enum.map(&{Map.get(&1, field), &1.id})
      |> List.insert_at(0, {"None", ""})
    end

    def selected(items = [ _ | _]) do
      items
      |> Enum.map(fn(x) -> (x.id) end)
    end
    def selected(_items), do: []

  @doc """
  Attempts to get the parent id from the assigns.  If it doesn't exist, it gets
  the id of the relation.  For example:

    DomainHelpers.maybe_parent_id(assigns, :page_id)

  Would return the parent ID, if the element has a parent.  It would return the
  page ID if it didn't.  This is used to populate the foreign key of a relationship
  on a form.  It will be the parent id if it's a new record, or the existing id
  if you're editing the record.
  """
  def maybe_parent_id(assigns, field) do
    try do
      assigns.parent.id
    rescue
      ArgumentError -> Map.get(assigns.changeset.data, field)
      KeyError -> Map.get(assigns.changeset.data, field)
    end
  end

  end
