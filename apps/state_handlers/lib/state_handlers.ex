defmodule StateHandlers do
  @moduledoc """
  Documentation for `State`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> State.hello()
      :world

  """
  def load(state, data, schema, opts), do: StateHandlers.Load.apply(state, data, schema, opts)
  def get(state, id, opts), do: StateHandlers.Get.apply(state, id, opts)
  def get(state, id, schema, opts), do: StateHandlers.Get.apply(state, id, schema, opts)
  def preload(state, data, preloads, opts), do: StateHandlers.Preload.apply(state, data, preloads, opts)
  def list(state, schema, opts), do: StateHandlers.List.apply(state, schema, opts)
end
