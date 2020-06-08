defmodule UserDocsWeb.ArgLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Automation

  @create_attrs %{key: "some key", value: "some value"}
  @update_attrs %{key: "some updated key", value: "some updated value"}
  @invalid_attrs %{key: nil, value: nil}

  defp fixture(:arg) do
    {:ok, arg} = Automation.create_arg(@create_attrs)
    arg
  end

  defp create_arg(_) do
    arg = fixture(:arg)
    %{arg: arg}
  end

  describe "Index" do
    setup [:create_arg]

    test "lists all args", %{conn: conn, arg: arg} do
      {:ok, _index_live, html} = live(conn, Routes.arg_index_path(conn, :index))

      assert html =~ "Listing Args"
      assert html =~ arg.key
    end

    test "saves new arg", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.arg_index_path(conn, :index))

      assert index_live |> element("a", "New Arg") |> render_click() =~
               "New Arg"

      assert_patch(index_live, Routes.arg_index_path(conn, :new))

      assert index_live
             |> form("#arg-form", arg: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#arg-form", arg: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.arg_index_path(conn, :index))

      assert html =~ "Arg created successfully"
      assert html =~ "some key"
    end

    test "updates arg in listing", %{conn: conn, arg: arg} do
      {:ok, index_live, _html} = live(conn, Routes.arg_index_path(conn, :index))

      assert index_live |> element("#arg-#{arg.id} a", "Edit") |> render_click() =~
               "Edit Arg"

      assert_patch(index_live, Routes.arg_index_path(conn, :edit, arg))

      assert index_live
             |> form("#arg-form", arg: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#arg-form", arg: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.arg_index_path(conn, :index))

      assert html =~ "Arg updated successfully"
      assert html =~ "some updated key"
    end

    test "deletes arg in listing", %{conn: conn, arg: arg} do
      {:ok, index_live, _html} = live(conn, Routes.arg_index_path(conn, :index))

      assert index_live |> element("#arg-#{arg.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#arg-#{arg.id}")
    end
  end

  describe "Show" do
    setup [:create_arg]

    test "displays arg", %{conn: conn, arg: arg} do
      {:ok, _show_live, html} = live(conn, Routes.arg_show_path(conn, :show, arg))

      assert html =~ "Show Arg"
      assert html =~ arg.key
    end

    test "updates arg within modal", %{conn: conn, arg: arg} do
      {:ok, show_live, _html} = live(conn, Routes.arg_show_path(conn, :show, arg))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Arg"

      assert_patch(show_live, Routes.arg_show_path(conn, :edit, arg))

      assert show_live
             |> form("#arg-form", arg: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#arg-form", arg: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.arg_show_path(conn, :show, arg))

      assert html =~ "Arg updated successfully"
      assert html =~ "some updated key"
    end
  end
end
