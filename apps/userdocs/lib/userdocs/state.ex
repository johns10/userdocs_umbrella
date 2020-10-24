defmodule UserDocs.State do
  require Logger

  #You can pass in a list (IE socket.assigns.data.projects)
  def get!(state, id, _key, _module) when is_list(state) do
    get!(state, id)
  end
  #You can pass in the state (IE socket.assigns.data), and it'll go get the list
  def get!(state, id, key, _module) do
    # Logger.debug("Querying id: #{id}, Keys in state #{inspect(Map.keys(state))}")
    get!(Map.get(state, key), id)
  end
  def get!(nil, id), do: raise(RuntimeError, "Couldn't find the datatype in the state.")
  # Here's the actual work
  def get!(objects, id) when is_list(objects) do
    objects
    |> Enum.filter(fn(o) -> o.id == id end)
    |> Enum.at(0)
  end
end
