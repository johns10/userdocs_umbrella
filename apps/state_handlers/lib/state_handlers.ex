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
  def load(state, data, opts), do: StateHandlers.Load.apply(state, data, opts)
  def get(state, id, opts), do: StateHandlers.Get.apply(state, id, opts)
  def get(state, id, schema, opts), do: StateHandlers.Get.apply(state, id, schema, opts)
  def preload(state, data, preloads, opts), do: StateHandlers.Preload.apply(state, data, preloads, opts)
  def preload(state, data, opts), do: StateHandlers.Preload.apply(state, data, opts)
  def list(state, schema, opts), do: StateHandlers.List.apply(state, schema, opts)
  def create(state, data, opts), do: StateHandlers.Create.apply(state, data, opts)
  def inspect(state, opts), do: StateHandlers.Inspect.apply(state, opts)
  def initialize(state, opts), do: StateHandlers.Initialize.apply(state, opts)
  def delete(state, data, opts), do: StateHandlers.Delete.apply(state, data, opts)
end
