defmodule TestData1 do
  defstruct(
    first_name: "",
    id: 0,
    last_name: ""
  )
end

defmodule TestData2 do
  defstruct(
    id: 0,
    name: "",
    test_data_1: ""
  )
end

defmodule TestState do
  defstruct(
    test_data_1: [
      %TestData1{
        first_name: "John",
        id: 1,
        last_name: "Jones"
      },
      %TestData1{
        first_name: "Davy",
        id: 2,
        last_name: "Crocket"
      },
      %TestData1{
        first_name: "Jane",
        id: 3,
        last_name: "Smith"
      }
    ],
    test_data_2: [
      %TestData2{
        name: "Test 1",
        id: 1,
        test_data_1: 1
      },
      %TestData2{
        name: "Test 2",
        id: 2,
        test_data_1: 1
      },
      %TestData2{
        name: "Test 3",
        id: 3,
        test_data_1: 3
      },
      %TestData2{
        name: "Test 4",
        id: 4,
        test_data_1: 2
      }
    ]
  )
end

defmodule StructStateHandlersTest do
  use ExUnit.Case
  doctest StateHandlers

  test "gets an object from a struct state" do
    expected_result = [ %TestData1{ first_name: "John", id: 1, last_name: "Jones" } ]
    { _state, result } = StateHandlers.get(
      %TestState{},
      :test_data_1,
      [1]
    )
    assert(result == expected_result)
  end

  test "gets all the objects from a struct state" do
    expected_result = %TestState{}.test_data_1
    { _state, result } = StateHandlers.get(
      %TestState{},
      :test_data_1,
      []
    )
    assert result == expected_result
  end

  test "gets multiple objects from a struct state" do
    ids = [ 1, 3 ]
    expected_result = Enum.filter(
      %TestState{}.test_data_1,
      fn(x) -> x.id in ids end
    )
    { _state, result } = StateHandlers.get(
      %TestState{},
      :test_data_1,
      ids
    )
    assert result == expected_result
  end

  test "creates a struct object" do
    object = %TestData1{
      first_name: "Davy",
      id: 100,
      last_name: "Crocket"
    }
    { state, data } = StateHandlers.create(
      %TestState{},
      :test_data_1,
      object
    )
    assert state == Map.put(
      %TestState{},
      :test_data_1,
      [ object | %TestState{}.test_data_1 ]
      )
    assert data == [ object ]
  end

  test "updates an object" do
    { _state, object } = StateHandlers.get(
      %TestState{},
      :test_data_1,
      [3]
    )
    updated_object = Enum.at(object, 0)
    |> Map.put(:first_name, "Thousand")
    |> Map.put(:last_name, "Island")
    { updated_state, result } = StateHandlers.update(
      %TestState{},
      :test_data_1,
      updated_object
    )
    expected_state = [ updated_object | List.delete(%TestState{}.test_data_1, Enum.at(object, 0)) ]
    assert updated_state.test_data_1 == expected_state
    assert result == [ updated_object ]
  end

  test "deletes an object" do
    { state, object } = StateHandlers.get(
      %TestState{},
      :test_data_1,
      [ 1 ]
    )
    object = Enum.at(object, 0)
    updated_state = StateHandlers.delete(
      %TestState{},
      :test_data_1,
      object
    )
    assert List.delete(state.test_data_1, object) == updated_state.test_data_1
  end

  test "get related data returns related data" do
    expected_result = [
      %TestData2{id: 1, name: "Test 1", test_data_1: 1},
      %TestData2{id: 2, name: "Test 2", test_data_1: 1},
      %TestData2{id: 3, name: "Test 3", test_data_1: 3}
    ]
    { _state, data } = StateHandlers.get_related(
      %TestState{},
      :test_data_1,
      [
        %TestData1{ id: 1 },
        %TestData1{ id: 3 }
      ],
      :test_data_2
    )
    assert data == expected_result
  end

end
