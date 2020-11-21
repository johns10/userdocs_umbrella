defmodule UserDocs.State do
  require Logger
  use Agent

  def start_link(state, name) do
    Agent.start_link(fn -> state end, name: name)
  end

  def load(name, data, opts) do
    Agent.get(name,
      fn(state) -> StateHandlers.load(state, data, opts) end
    )
  end

  def get(name, id, opts) do
    Agent.get(name,
      fn(state) -> StateHandlers.get(state, id, opts) end
    )
  end



  #You can pass in a list (IE socket.assigns.data.projects)
  def get!(state, id, _key, _module) when is_list(state) do
    get!(state, id)
  end
  #You can pass in the socket (IE socket.assigns), and it'll go get the data
  def get!(%{ data: data }, id, key, _module) do
    # Logger.debug("Querying id: #{id}, Keys in state #{inspect(Map.keys(state))}")
    get!(Map.get(data, key), id)
  end
  #You can pass in the state (IE socket.assigns.data), and it'll go get the list
  def get!(state, id, key, _module) do
    # Logger.debug("Querying id: #{id}, Keys in state #{inspect(Map.keys(state))}")
    get!(Map.get(state, key), id)
  end
  # def get!(_, nil), do: nil  Should go in
  def get!(nil, _id), do: raise(RuntimeError, "Couldn't find the datatype in the state.")
  # Here's the actual work
  def get!(objects, id) when is_list(objects) do
    objects
    |> Enum.filter(fn(o) -> o.id == id end)
    |> Enum.at(0)
  end

  def get(state, key, _module) do
    Map.get(state, key)
  end
end
