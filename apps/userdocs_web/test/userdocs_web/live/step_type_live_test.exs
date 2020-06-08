defmodule UserDocsWeb.StepTypeLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Automation

  @create_attrs %{args: ["option1"], name: "some name"}
  @update_attrs %{args: ["option2"], name: "some updated name"}
  @invalid_attrs %{args: ["option1"], name: nil}

  defp fixture(:step_type) do
    {:ok, step_type} = Automation.create_step_type(@create_attrs)
    step_type
  end

  defp create_step_type(_) do
    step_type = fixture(:step_type)
    %{step_type: step_type}
  end

  describe "Index" do
    #TODO: This only tests that the first arg is in the response. Fix it.
    setup [:create_step_type]

    test "lists all step_types", %{conn: conn, step_type: step_type} do
      {:ok, _index_live, html} = live(conn, Routes.step_type_index_path(conn, :index))

      assert html =~ "Listing Step types"
      assert html =~ Enum.at(step_type.args, 0)
    end

    test "saves new step_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.step_type_index_path(conn, :index))

      assert index_live |> element("a", "New Step type") |> render_click() =~
               "New Step type"

      assert_patch(index_live, Routes.step_type_index_path(conn, :new))

      assert index_live
             |> form("#step_type-form", step_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#step_type-form", step_type: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_type_index_path(conn, :index))

      assert html =~ "Step type created successfully"
      assert html =~ Enum.at(@create_attrs.args, 0)
    end

    test "updates step_type in listing", %{conn: conn, step_type: step_type} do
      {:ok, index_live, _html} = live(conn, Routes.step_type_index_path(conn, :index))

      assert index_live |> element("#step_type-#{step_type.id} a", "Edit") |> render_click() =~
               "Edit Step type"

      assert_patch(index_live, Routes.step_type_index_path(conn, :edit, step_type))

      assert index_live
             |> form("#step_type-form", step_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#step_type-form", step_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_type_index_path(conn, :index))

      assert html =~ "Step type updated successfully"
      assert html =~ Enum.at(@update_attrs.args, 0)
    end

    test "deletes step_type in listing", %{conn: conn, step_type: step_type} do
      {:ok, index_live, _html} = live(conn, Routes.step_type_index_path(conn, :index))

      assert index_live 
      |> element("#step_type-#{step_type.id} a", "Delete") 
      |> render_click()

      refute has_element?(index_live, "#step_type-#{step_type.id}")
    end
  end

  describe "Show" do
    setup [:create_step_type]

    test "displays step_type", %{conn: conn, step_type: step_type} do
      {:ok, _show_live, html} = live(conn, Routes.step_type_show_path(conn, :show, step_type))

      assert html =~ "Show Step type"
      assert html =~ Enum.at(step_type.args, 0)
    end

    test "updates step_type within modal", %{conn: conn, step_type: step_type} do
      {:ok, show_live, _html} = live(conn, Routes.step_type_show_path(conn, :show, step_type))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Step type"

      assert_patch(show_live, Routes.step_type_show_path(conn, :edit, step_type))

      assert show_live
             |> form("#step_type-form", step_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#step_type-form", step_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_type_show_path(conn, :show, step_type))

      assert html =~ "Step type updated successfully"
      assert html =~ Enum.at(@update_attrs.args, 0)
    end
  end
end
