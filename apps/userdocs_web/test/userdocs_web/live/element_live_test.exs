defmodule UserDocsWeb.ElementLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Elements

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp fixture(:element) do
    {:ok, element} = Elements.create_element(@create_attrs)
    element
  end

  defp create_element(_) do
    element = fixture(:element)
    %{element: element}
  end

  describe "Index" do
    setup [:create_element]

    test "lists all elements", %{conn: conn, element: element} do
      {:ok, _index_live, html} = live(conn, Routes.element_index_path(conn, :index))

      assert html =~ "Listing Elements"
    end

    test "saves new element", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.element_index_path(conn, :index))

      assert index_live |> element("a", "New Element") |> render_click() =~
               "New Element"

      assert_patch(index_live, Routes.element_index_path(conn, :new))

      assert index_live
             |> form("#element-form", element: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#element-form", element: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.element_index_path(conn, :index))

      assert html =~ "Element created successfully"
    end

    test "updates element in listing", %{conn: conn, element: element} do
      {:ok, index_live, _html} = live(conn, Routes.element_index_path(conn, :index))

      assert index_live |> element("#element-#{element.id} a", "Edit") |> render_click() =~
               "Edit Element"

      assert_patch(index_live, Routes.element_index_path(conn, :edit, element))

      assert index_live
             |> form("#element-form", element: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#element-form", element: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.element_index_path(conn, :index))

      assert html =~ "Element updated successfully"
    end

    test "deletes element in listing", %{conn: conn, element: element} do
      {:ok, index_live, _html} = live(conn, Routes.element_index_path(conn, :index))

      assert index_live |> element("#element-#{element.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#element-#{element.id}")
    end
  end
end
