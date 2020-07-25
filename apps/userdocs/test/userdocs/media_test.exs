defmodule UserDocs.MediaTest do
  use UserDocs.DataCase

  alias UserDocs.Media

  describe "files" do
    alias UserDocs.Media.File

    @valid_attrs %{content_type: "some content_type", filename: "some filename", hash: "some hash", size: 42}
    @update_attrs %{content_type: "some updated content_type", filename: "some updated filename", hash: "some updated hash", size: 43}
    @invalid_attrs %{content_type: nil, filename: nil, hash: nil, size: nil}

    def file_fixture(attrs \\ %{}) do
      {:ok, file} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_file()

      file
    end

    test "list_files/0 returns all files" do
      file = file_fixture()
      assert Media.list_files() == [file]
    end

    test "get_file!/1 returns the file with given id" do
      file = file_fixture()
      assert Media.get_file!(file.id) == file
    end

    test "create_file/1 with valid data creates a file" do
      assert {:ok, %File{} = file} = Media.create_file(@valid_attrs)
      assert file.content_type == "some content_type"
      assert file.filename == "some filename"
      assert file.hash == "some hash"
      assert file.size == 42
    end

    test "create_file/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_file(@invalid_attrs)
    end

    test "update_file/2 with valid data updates the file" do
      file = file_fixture()
      assert {:ok, %File{} = file} = Media.update_file(file, @update_attrs)
      assert file.content_type == "some updated content_type"
      assert file.filename == "some updated filename"
      assert file.hash == "some updated hash"
      assert file.size == 43
    end

    test "update_file/2 with invalid data returns error changeset" do
      file = file_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_file(file, @invalid_attrs)
      assert file == Media.get_file!(file.id)
    end

    test "delete_file/1 deletes the file" do
      file = file_fixture()
      assert {:ok, %File{}} = Media.delete_file(file)
      assert_raise Ecto.NoResultsError, fn -> Media.get_file!(file.id) end
    end

    test "change_file/1 returns a file changeset" do
      file = file_fixture()
      assert %Ecto.Changeset{} = Media.change_file(file)
    end
  end
end
