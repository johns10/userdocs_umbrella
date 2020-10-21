defmodule UserDocsWeb.LanguageCodeLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Documents

  @create_attrs %{code: "some code"}
  @update_attrs %{code: "some updated code"}
  @invalid_attrs %{code: nil}

  defp fixture(:language_code) do
    {:ok, language_code} = Documents.create_language_code(@create_attrs)
    language_code
  end

  defp create_language_code(_) do
    language_code = fixture(:language_code)
    %{language_code: language_code}
  end

  describe "Index" do
    setup [:create_language_code]

    test "lists all language_codes", %{conn: conn, language_code: language_code} do
      {:ok, _index_live, html} = live(conn, Routes.language_code_index_path(conn, :index))

      assert html =~ "Listing Language codes"
      assert html =~ language_code.code
    end

    test "saves new language_code", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.language_code_index_path(conn, :index))

      assert index_live |> element("a", "New Language code") |> render_click() =~
               "New Language code"

      assert_patch(index_live, Routes.language_code_index_path(conn, :new))

      assert index_live
             |> form("#language_code-form", language_code: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#language_code-form", language_code: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.language_code_index_path(conn, :index))

      assert html =~ "Language code created successfully"
      assert html =~ "some code"
    end

    test "updates language_code in listing", %{conn: conn, language_code: language_code} do
      {:ok, index_live, _html} = live(conn, Routes.language_code_index_path(conn, :index))

      assert index_live |> element("#language_code-#{language_code.id} a", "Edit") |> render_click() =~
               "Edit Language code"

      assert_patch(index_live, Routes.language_code_index_path(conn, :edit, language_code))

      assert index_live
             |> form("#language_code-form", language_code: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#language_code-form", language_code: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.language_code_index_path(conn, :index))

      assert html =~ "Language code updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes language_code in listing", %{conn: conn, language_code: language_code} do
      {:ok, index_live, _html} = live(conn, Routes.language_code_index_path(conn, :index))

      assert index_live |> element("#language_code-#{language_code.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#language_code-#{language_code.id}")
    end
  end

  describe "Show" do
    setup [:create_language_code]

    test "displays language_code", %{conn: conn, language_code: language_code} do
      {:ok, _show_live, html} = live(conn, Routes.language_code_show_path(conn, :show, language_code))

      assert html =~ "Show Language code"
      assert html =~ language_code.code
    end

    test "updates language_code within modal", %{conn: conn, language_code: language_code} do
      {:ok, show_live, _html} = live(conn, Routes.language_code_show_path(conn, :show, language_code))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Language code"

      assert_patch(show_live, Routes.language_code_show_path(conn, :edit, language_code))

      assert show_live
             |> form("#language_code-form", language_code: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#language_code-form", language_code: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.language_code_show_path(conn, :show, language_code))

      assert html =~ "Language code updated successfully"
      assert html =~ "some updated code"
    end
  end
end
