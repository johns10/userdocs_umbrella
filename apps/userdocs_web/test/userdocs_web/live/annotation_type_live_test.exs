defmodule UserDocsWeb.AnnotationTypeLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Web

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp fixture(:annotation_type) do
    {:ok, annotation_type} = Web.create_annotation_type(@create_attrs)
    annotation_type
  end

  defp create_annotation_type(_) do
    annotation_type = fixture(:annotation_type)
    %{annotation_type: annotation_type}
  end

  describe "Index" do
    setup [:create_annotation_type]

    test "lists all annotation_types", %{conn: conn, annotation_type: annotation_type} do
      {:ok, _index_live, html} = live(conn, Routes.annotation_type_index_path(conn, :index))

      assert html =~ "Listing Annotation types"
      assert html =~ annotation_type.name
    end

    test "saves new annotation_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.annotation_type_index_path(conn, :index))

      assert index_live |> element("a", "New Annotation type") |> render_click() =~
               "New Annotation type"

      assert_patch(index_live, Routes.annotation_type_index_path(conn, :new))

      assert index_live
             |> form("#annotation_type-form", annotation_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#annotation_type-form", annotation_type: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.annotation_type_index_path(conn, :index))

      assert html =~ "Annotation type created successfully"
      assert html =~ "some name"
    end

    test "updates annotation_type in listing", %{conn: conn, annotation_type: annotation_type} do
      {:ok, index_live, _html} = live(conn, Routes.annotation_type_index_path(conn, :index))

      assert index_live |> element("#annotation_type-#{annotation_type.id} a", "Edit") |> render_click() =~
               "Edit Annotation type"

      assert_patch(index_live, Routes.annotation_type_index_path(conn, :edit, annotation_type))

      assert index_live
             |> form("#annotation_type-form", annotation_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#annotation_type-form", annotation_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.annotation_type_index_path(conn, :index))

      assert html =~ "Annotation type updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes annotation_type in listing", %{conn: conn, annotation_type: annotation_type} do
      {:ok, index_live, _html} = live(conn, Routes.annotation_type_index_path(conn, :index))

      assert index_live |> element("#annotation_type-#{annotation_type.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#annotation_type-#{annotation_type.id}")
    end
  end

  describe "Show" do
    setup [:create_annotation_type]

    test "displays annotation_type", %{conn: conn, annotation_type: annotation_type} do
      {:ok, _show_live, html} = live(conn, Routes.annotation_type_show_path(conn, :show, annotation_type))

      assert html =~ "Show Annotation type"
      assert html =~ annotation_type.name
    end

    test "updates annotation_type within modal", %{conn: conn, annotation_type: annotation_type} do
      {:ok, show_live, _html} = live(conn, Routes.annotation_type_show_path(conn, :show, annotation_type))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Annotation type"

      assert_patch(show_live, Routes.annotation_type_show_path(conn, :edit, annotation_type))

      assert show_live
             |> form("#annotation_type-form", annotation_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#annotation_type-form", annotation_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.annotation_type_show_path(conn, :show, annotation_type))

      assert html =~ "Annotation type updated successfully"
      assert html =~ "some updated name"
    end
  end
end
