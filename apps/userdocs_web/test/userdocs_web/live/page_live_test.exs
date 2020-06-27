defmodule UserDocsWeb.PageLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Web
  alias UserDocs.Projects

  @version_attrs %{name: "some name"}

  @create_attrs %{name: "some name", url: "some url"}
  @update_attrs %{name: "some updated name", url: "some updated url"}
  @invalid_attrs %{name: nil, url: nil}

  defp first_version_id() do
    Projects.list_versions()
    |> Enum.at(0)
    |> Map.get(:id)
  end

  defp fixture(:version) do
    {:ok, version} = Projects.create_version(@version_attrs)
    version
  end
  defp fixture(:page) do
    {:ok, page} = Web.create_page(@create_attrs)
    page
  end

  defp create_version(_) do
    version = fixture(:version)
    %{version: version}
  end

  defp create_page(_) do
    page = fixture(:page)
    %{page: page}
  end

  describe "Index" do
    setup [:create_version, :create_page]

    test "lists all pages", %{conn: conn, page: page} do
      {:ok, _index_live, html} = live(conn, Routes.page_index_path(conn, :index))

      assert html =~ "Listing Pages"
      assert html =~ page.url
    end

    test "saves new page", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.page_index_path(conn, :index))

      assert index_live
      |> element("a", "New Page")
      |> render_click() =~ "New Page"

      assert_patch(index_live, Routes.page_index_path(conn, :new))

      assert index_live
      |> form("#page-form", page: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      page_attrs = Map.put(
        @create_attrs,
        :version_id,
        first_version_id()
      )

      {:ok, _, html} =
        index_live
        |> form("#page-form", page: page_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.page_index_path(conn, :index))

      assert html =~ "Page created successfully"
      assert html =~ "some url"
    end

    test "updates page in listing", %{conn: conn, page: page} do
      {:ok, index_live, _html} = live(conn, Routes.page_index_path(conn, :index))

      assert index_live |> element("#page-#{page.id} a", "Edit") |> render_click() =~
               "Edit Page"

      assert_patch(index_live, Routes.page_index_path(conn, :edit, page))

      assert index_live
      |> form("#page-form", page: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      update_attrs = Map.put(
        @update_attrs,
        :version_id,
        first_version_id()
      )

      {:ok, _, html} =
        index_live
        |> form("#page-form", page: update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.page_index_path(conn, :index))

      assert html =~ "Page updated successfully"
      assert html =~ "some updated url"
    end

    test "deletes page in listing", %{conn: conn, page: page} do
      {:ok, index_live, _html} = live(conn, Routes.page_index_path(conn, :index))

      assert index_live |> element("#page-#{page.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#page-#{page.id}")
    end
  end

  describe "Show" do
    setup [:create_version, :create_page]

    test "displays page", %{conn: conn, page: page} do
      {:ok, _show_live, html} = live(conn, Routes.page_show_path(conn, :show, page))

      assert html =~ "Show Page"
      assert html =~ page.url
    end

    test "updates page within modal", %{conn: conn, page: page} do
      {:ok, show_live, _html} = live(conn, Routes.page_show_path(conn, :show, page))

      assert show_live
      |> element("a", "Edit")
      |> render_click() =~ "Edit Page"

      assert_patch(show_live, Routes.page_show_path(conn, :edit, page))

      assert show_live
      |> form("#page-form", page: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      update_attrs = Map.put(
        @update_attrs,
        :version_id,
        first_version_id()
      )

      {:ok, _, html} =
        show_live
        |> form("#page-form", page: update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.page_show_path(conn, :show, page))

      assert html =~ "Page updated successfully"
      assert html =~ "some updated url"
    end
  end
end
