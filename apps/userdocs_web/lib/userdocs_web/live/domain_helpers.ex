defmodule UserDocsWeb.DomainHelpers do
  
    @doc """
    
    """
    def build_select_list(query, field \\ :name) do
        query
        |> Enum.map(&{Map.get(&1, field), &1.id})
        |> List.insert_at(0, {"None", None})
    end
  end
  