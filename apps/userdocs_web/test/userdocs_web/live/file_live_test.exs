defmodule UserDocsWeb.FileLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Media

  @create_attrs %{content_type: "some content_type", filename: "some filename", hash: "some hash", size: 42}
  @update_attrs %{content_type: "some updated content_type", filename: "some updated filename", hash: "some updated hash", size: 43}
  @invalid_attrs %{content_type: nil, filename: nil, hash: nil, size: nil}

  defp fixture(:file) do
    {:ok, file} = Media.create_file(@create_attrs)
    file
  end

  defp create_file(_) do
    file = fixture(:file)
    %{file: file}
  end

  describe "Index" do
    setup [:create_file]

    test "lists all files", %{conn: conn, file: file} do
      {:ok, _index_live, html} = live(conn, Routes.file_index_path(conn, :index))

      assert html =~ "Listing Files"
      assert html =~ file.content_type
    end

    test "saves new file", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.file_index_path(conn, :index))

      assert index_live |> element("a", "New File") |> render_click() =~
               "New File"

      assert_patch(index_live, Routes.file_index_path(conn, :new))

      assert index_live
             |> form("#file-form", file: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#file-form", file: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.file_index_path(conn, :index))

      assert html =~ "File created successfully"
      assert html =~ "some content_type"
    end

    test "updates file in listing", %{conn: conn, file: file} do
      {:ok, index_live, _html} = live(conn, Routes.file_index_path(conn, :index))

      assert index_live |> element("#file-#{file.id} a", "Edit") |> render_click() =~
               "Edit File"

      assert_patch(index_live, Routes.file_index_path(conn, :edit, file))

      assert index_live
             |> form("#file-form", file: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#file-form", file: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.file_index_path(conn, :index))

      assert html =~ "File updated successfully"
      assert html =~ "some updated content_type"
    end

    test "deletes file in listing", %{conn: conn, file: file} do
      {:ok, index_live, _html} = live(conn, Routes.file_index_path(conn, :index))

      assert index_live |> element("#file-#{file.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#file-#{file.id}")
    end
  end

  describe "Show" do
    setup [:create_file]

    test "displays file", %{conn: conn, file: file} do
      {:ok, _show_live, html} = live(conn, Routes.file_show_path(conn, :show, file))

      assert html =~ "Show File"
      assert html =~ file.content_type
    end

    test "updates file within modal", %{conn: conn, file: file} do
      {:ok, show_live, _html} = live(conn, Routes.file_show_path(conn, :show, file))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit File"

      assert_patch(show_live, Routes.file_show_path(conn, :edit, file))

      assert show_live
             |> form("#file-form", file: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#file-form", file: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.file_show_path(conn, :show, file))

      assert html =~ "File updated successfully"
      assert html =~ "some updated content_type"
    end
  end
end
