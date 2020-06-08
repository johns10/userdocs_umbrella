defmodule UserDocs.DocumentsTest do
  use UserDocs.DataCase

  alias UserDocs.Documents

  describe "content" do
    alias UserDocs.Documents.Content

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def content_fixture(attrs \\ %{}) do
      {:ok, content} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Documents.create_content()

      content
    end

    test "list_content/0 returns all content" do
      content = content_fixture()
      assert Documents.list_content() == [content]
    end

    test "get_content!/1 returns the content with given id" do
      content = content_fixture()
      assert Documents.get_content!(content.id) == content
    end

    test "create_content/1 with valid data creates a content" do
      assert {:ok, %Content{} = content} = Documents.create_content(@valid_attrs)
      assert content.description == "some description"
      assert content.name == "some name"
    end

    test "create_content/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_content(@invalid_attrs)
    end

    test "update_content/2 with valid data updates the content" do
      content = content_fixture()
      assert {:ok, %Content{} = content} = Documents.update_content(content, @update_attrs)
      assert content.description == "some updated description"
      assert content.name == "some updated name"
    end

    test "update_content/2 with invalid data returns error changeset" do
      content = content_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_content(content, @invalid_attrs)
      assert content == Documents.get_content!(content.id)
    end

    test "delete_content/1 deletes the content" do
      content = content_fixture()
      assert {:ok, %Content{}} = Documents.delete_content(content)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_content!(content.id) end
    end

    test "change_content/1 returns a content changeset" do
      content = content_fixture()
      assert %Ecto.Changeset{} = Documents.change_content(content)
    end
  end
end
