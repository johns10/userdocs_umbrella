defmodule State do
  @moduledoc """
  Documentation for `State`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> State.hello()
      :world

  """
  def load(state, data, opts), do: State.Load.apply(state, data, opts)
  def get(state, id, opts), do: State.Get.apply(state, id, opts)
end
