defmodule UserDocsWeb.ContentVersionLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Documents

  @create_attrs %{body: "some body", language_code: "some language_code", name: "some name"}
  @update_attrs %{body: "some updated body", language_code: "some updated language_code", name: "some updated name"}
  @invalid_attrs %{body: nil, language_code: nil, name: nil}

  defp fixture(:content_version) do
    {:ok, content_version} = Documents.create_content_version(@create_attrs)
    content_version
  end

  defp create_content_version(_) do
    content_version = fixture(:content_version)
    %{content_version: content_version}
  end

  describe "Index" do
    setup [:create_content_version]

    test "lists all content_versions", %{conn: conn, content_version: content_version} do
      {:ok, _index_live, html} = live(conn, Routes.content_version_index_path(conn, :index))

      assert html =~ "Listing Content versions"
      assert html =~ content_version.body
    end

    test "saves new content_version", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.content_version_index_path(conn, :index))

      assert index_live |> element("a", "New Content version") |> render_click() =~
               "New Content version"

      assert_patch(index_live, Routes.content_version_index_path(conn, :new))

      assert index_live
             |> form("#content_version-form", content_version: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#content_version-form", content_version: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_version_index_path(conn, :index))

      assert html =~ "Content version created successfully"
      assert html =~ "some body"
    end

    test "updates content_version in listing", %{conn: conn, content_version: content_version} do
      {:ok, index_live, _html} = live(conn, Routes.content_version_index_path(conn, :index))

      assert index_live |> element("#content_version-#{content_version.id} a", "Edit") |> render_click() =~
               "Edit Content version"

      assert_patch(index_live, Routes.content_version_index_path(conn, :edit, content_version))

      assert index_live
             |> form("#content_version-form", content_version: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#content_version-form", content_version: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_version_index_path(conn, :index))

      assert html =~ "Content version updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes content_version in listing", %{conn: conn, content_version: content_version} do
      {:ok, index_live, _html} = live(conn, Routes.content_version_index_path(conn, :index))

      assert index_live |> element("#content_version-#{content_version.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#content_version-#{content_version.id}")
    end
  end

  describe "Show" do
    setup [:create_content_version]

    test "displays content_version", %{conn: conn, content_version: content_version} do
      {:ok, _show_live, html} = live(conn, Routes.content_version_show_path(conn, :show, content_version))

      assert html =~ "Show Content version"
      assert html =~ content_version.body
    end

    test "updates content_version within modal", %{conn: conn, content_version: content_version} do
      {:ok, show_live, _html} = live(conn, Routes.content_version_show_path(conn, :show, content_version))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Content version"

      assert_patch(show_live, Routes.content_version_show_path(conn, :edit, content_version))

      assert show_live
             |> form("#content_version-form", content_version: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#content_version-form", content_version: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_version_show_path(conn, :show, content_version))

      assert html =~ "Content version updated successfully"
      assert html =~ "some updated body"
    end
  end
end
