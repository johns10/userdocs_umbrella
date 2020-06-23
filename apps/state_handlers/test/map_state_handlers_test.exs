defmodule MapStateHandlersTest do
  use ExUnit.Case
  doctest StateHandlers

  """

  test "gets an object from map" do
    { state, data } = StateHandlers.get(
      %{test: %{test_one: %{a: 1}}},
      :test,
      [:test_one]
    )
    assert state == %{test: %{test_one: %{a: 1}}}
    assert data == %{test_one: %{a: 1}}
  end


  test "creates an object" do
    { state, data } = StateHandlers.create(
      %{ test: %{} },
      :test,
      :test_one,
      %{ a: 1 }
    )
    assert state == %{test: %{test_one: %{a: 1}}}
    assert data == %{test_one: %{a: 1}}
  end

  test "updates an object" do
    { state, data } = StateHandlers.update(
      %{test: %{test_one: %{a: 1}}},
      :test,
      :test_one,
      %{ a: 2 }
    )
    assert state == %{test: %{test_one: %{a: 2}}}
    assert data == %{test_one: %{a: 2}}
  end

  test "deletes an object" do
    { state, data } = StateHandlers.delete(
      %{test: %{test_one: %{a: 1}}},
      :test,
      :test_one
    )
    assert state == %{test: %{}}
    assert data == :test_one
  end

  """

end
