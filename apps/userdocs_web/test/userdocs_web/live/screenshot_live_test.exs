defmodule UserDocsWeb.ScreenshotLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Media

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp fixture(:screenshot) do
    {:ok, screenshot} = Media.create_screenshot(@create_attrs)
    screenshot
  end

  defp create_screenshot(_) do
    screenshot = fixture(:screenshot)
    %{screenshot: screenshot}
  end

  describe "Index" do
    setup [:create_screenshot]

    test "lists all screenshots", %{conn: conn, screenshot: screenshot} do
      {:ok, _index_live, html} = live(conn, Routes.screenshot_index_path(conn, :index))

      assert html =~ "Listing Screenshots"
      assert html =~ screenshot.name
    end

    test "saves new screenshot", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.screenshot_index_path(conn, :index))

      assert index_live |> element("a", "New Screenshot") |> render_click() =~
               "New Screenshot"

      assert_patch(index_live, Routes.screenshot_index_path(conn, :new))

      assert index_live
             |> form("#screenshot-form", screenshot: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#screenshot-form", screenshot: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.screenshot_index_path(conn, :index))

      assert html =~ "Screenshot created successfully"
      assert html =~ "some name"
    end

    test "updates screenshot in listing", %{conn: conn, screenshot: screenshot} do
      {:ok, index_live, _html} = live(conn, Routes.screenshot_index_path(conn, :index))

      assert index_live |> element("#screenshot-#{screenshot.id} a", "Edit") |> render_click() =~
               "Edit Screenshot"

      assert_patch(index_live, Routes.screenshot_index_path(conn, :edit, screenshot))

      assert index_live
             |> form("#screenshot-form", screenshot: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#screenshot-form", screenshot: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.screenshot_index_path(conn, :index))

      assert html =~ "Screenshot updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes screenshot in listing", %{conn: conn, screenshot: screenshot} do
      {:ok, index_live, _html} = live(conn, Routes.screenshot_index_path(conn, :index))

      assert index_live |> element("#screenshot-#{screenshot.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#screenshot-#{screenshot.id}")
    end
  end

  describe "Show" do
    setup [:create_screenshot]

    test "displays screenshot", %{conn: conn, screenshot: screenshot} do
      {:ok, _show_live, html} = live(conn, Routes.screenshot_show_path(conn, :show, screenshot))

      assert html =~ "Show Screenshot"
      assert html =~ screenshot.name
    end

    test "updates screenshot within modal", %{conn: conn, screenshot: screenshot} do
      {:ok, show_live, _html} = live(conn, Routes.screenshot_show_path(conn, :show, screenshot))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Screenshot"

      assert_patch(show_live, Routes.screenshot_show_path(conn, :edit, screenshot))

      assert show_live
             |> form("#screenshot-form", screenshot: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#screenshot-form", screenshot: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.screenshot_show_path(conn, :show, screenshot))

      assert html =~ "Screenshot updated successfully"
      assert html =~ "some updated name"
    end
  end
end
