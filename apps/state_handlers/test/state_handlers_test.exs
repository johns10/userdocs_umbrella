defmodule StateHandlersTest do
  use ExUnit.Case
  doctest StateHandlers

  test "greets the world" do
    assert StateHandlers.hello() == :world
  end
end
