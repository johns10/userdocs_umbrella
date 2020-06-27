defmodule UserDocsWeb.DomainHelpers do

    @doc """

    """
    def select_list(items, field \\ :name)
    def select_list([], _), do: [{"None", None}]
    def select_list(items, field) do
      items
      |> Enum.map(&{Map.get(&1, field), &1.id})
      |> List.insert_at(0, {"None", None})
    end

    def selected(items = [ _ | _]) do
      items
      |> Enum.map(fn(x) -> (x.id) end)
    end
    def selected(_items), do: []


  def maybe_parent_id(assigns, field) do
    try do
      assigns.parent.id
    rescue
      ArgumentError -> Map.get(assigns.changeset.data, field)
      KeyError -> Map.get(assigns.changeset.data, field)
    end
  end

  end
