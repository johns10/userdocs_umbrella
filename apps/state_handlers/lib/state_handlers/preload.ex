defmodule StateHandlers.Preload do

  alias StateHandlers.Helpers
  alias StateHandlers.Get

  def preload(state, data, preloads, opts) do

  end

  def apply(_, _, _), do: raise(RuntimeError, "State.Get failed to find a matching clause")
end
