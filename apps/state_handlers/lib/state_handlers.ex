defmodule StateHandlers do

  defdelegate get(state, type, ids \\ []), to: StateHandlers.Struct

  defdelegate get_related(state, from_type, from_data, to_type), to: StateHandlers.Struct

  defdelegate create(state, type, object), to: StateHandlers.Struct

  defdelegate update(state, type, object), to: StateHandlers.Struct

  defdelegate delete(state, type, id), to: StateHandlers.Struct

end
