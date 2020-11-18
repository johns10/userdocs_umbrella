defmodule State.Load do

  alias State.Helpers

  def apply(state, data, opts = %{ data_type: :map, strategy: :by_key }) do
    Enum.reduce(data, state,
      fn(d, s) ->
        Map.put(s, Helpers.id_key(d), d)
      end)
  end
end
