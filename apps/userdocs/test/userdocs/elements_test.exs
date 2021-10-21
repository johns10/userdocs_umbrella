defmodule UserDocs.ElementsTest do
  use UserDocs.DataCase

  alias UserDocs.Elements

  describe "elements" do
    alias UserDocs.Elements.Element

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def element_fixture(attrs \\ %{}) do
      {:ok, element} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Elements.create_element()

      element
    end

    test "list_elements/0 returns all elements" do
      element = element_fixture()
      assert Elements.list_elements() == [element]
    end

    test "get_element!/1 returns the element with given id" do
      element = element_fixture()
      assert Elements.get_element!(element.id) == element
    end

    test "create_element/1 with valid data creates a element" do
      assert {:ok, %Element{} = element} = Elements.create_element(@valid_attrs)
    end

    test "create_element/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Elements.create_element(@invalid_attrs)
    end

    test "update_element/2 with valid data updates the element" do
      element = element_fixture()
      assert {:ok, %Element{} = element} = Elements.update_element(element, @update_attrs)
    end

    test "update_element/2 with invalid data returns error changeset" do
      element = element_fixture()
      assert {:error, %Ecto.Changeset{}} = Elements.update_element(element, @invalid_attrs)
      assert element == Elements.get_element!(element.id)
    end

    test "delete_element/1 deletes the element" do
      element = element_fixture()
      assert {:ok, %Element{}} = Elements.delete_element(element)
      assert_raise Ecto.NoResultsError, fn -> Elements.get_element!(element.id) end
    end

    test "change_element/1 returns a element changeset" do
      element = element_fixture()
      assert %Ecto.Changeset{} = Elements.change_element(element)
    end
  end
end
