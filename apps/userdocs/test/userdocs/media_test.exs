defmodule UserDocs.MediaTest do
  use UserDocs.DataCase

  alias UserDocs.Media

  describe "screenshots" do
    alias UserDocs.Media.Screenshot

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def screenshot_fixture(attrs \\ %{}) do
      {:ok, screenshot} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_screenshot()

      screenshot
    end

    test "list_screenshots/0 returns all screenshots" do
      screenshot = screenshot_fixture()
      assert Media.list_screenshots() == [screenshot]
    end

    test "get_screenshot!/1 returns the screenshot with given id" do
      screenshot = screenshot_fixture()
      assert Media.get_screenshot!(screenshot.id) == screenshot
    end

    test "create_screenshot/1 with valid data creates a screenshot" do
      assert {:ok, %Screenshot{} = screenshot} = Media.create_screenshot(@valid_attrs)
      assert screenshot.name == "some name"
    end

    test "create_screenshot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_screenshot(@invalid_attrs)
    end

    test "update_screenshot/2 with valid data updates the screenshot" do
      screenshot = screenshot_fixture()
      assert {:ok, %Screenshot{} = screenshot} = Media.update_screenshot(screenshot, @update_attrs)
      assert screenshot.name == "some updated name"
    end

    test "update_screenshot/2 with invalid data returns error changeset" do
      screenshot = screenshot_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_screenshot(screenshot, @invalid_attrs)
      assert screenshot == Media.get_screenshot!(screenshot.id)
    end

    test "delete_screenshot/1 deletes the screenshot" do
      screenshot = screenshot_fixture()
      assert {:ok, %Screenshot{}} = Media.delete_screenshot(screenshot)
      assert_raise Ecto.NoResultsError, fn -> Media.get_screenshot!(screenshot.id) end
    end

    test "change_screenshot/1 returns a screenshot changeset" do
      screenshot = screenshot_fixture()
      assert %Ecto.Changeset{} = Media.change_screenshot(screenshot)
    end
  end
end
