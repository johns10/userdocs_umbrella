defmodule UserDocsWeb.StepLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Automation

  @process_attrs %{name: "valid_process"}

  @create_attrs %{order: 42}
  @update_attrs %{order: 43}
  @invalid_attrs %{order: nil}

  
  defp first_process_id() do
    Automation.list_processes()
    |> Enum.at(0)
    |> Map.get(:id)
  end

  defp fixture(:step) do
    step_attrs = Map.put(@create_attrs, :process_id, first_process_id())
    {:ok, step} = Automation.create_step(step_attrs)
    step
  end

  defp fixture(:process) do
    {:ok, process} = Automation.create_process(@process_attrs)
    process
  end
  
  defp create_step(_) do
    step = fixture(:step)
    %{step: step}
  end

  defp create_process(_) do
    process = fixture(:process)
    %{process: process}
  end

  describe "Index" do
    setup [:create_process, :create_step]

    test "lists all steps", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.step_index_path(conn, :index))

      assert html =~ "Listing Steps"
    end

    test "saves new step", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index))

      assert index_live 
      |> element("a", "New Step")   
      |> render_click() =~ "New Step"

      assert_patch(index_live, Routes.step_index_path(conn, :new))

      assert index_live
      |> form("#step-form", step: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      step_attrs = Map.put(@create_attrs, :process_id, first_process_id())

      {:ok, _, html} =
        index_live
        |> form("#step-form", step: step_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index))

      assert html =~ "Step created successfully"
    end

    test "updates step in listing", %{conn: conn, step: step} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index))

      assert index_live |> element("#step-#{step.id} a", "Edit") |> render_click() =~
               "Edit Step"

      assert_patch(index_live, Routes.step_index_path(conn, :edit, step))

      assert index_live
             |> form("#step-form", step: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#step-form", step: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index))

      assert html =~ "Step updated successfully"
    end

    test "deletes step in listing", %{conn: conn, step: step} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index))

      assert index_live |> element("#step-#{step.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#step-#{step.id}")
    end
  end

  describe "Show" do
    setup [:create_process, :create_step]

    test "displays step", %{conn: conn, step: step} do
      {:ok, _show_live, html} = live(conn, Routes.step_show_path(conn, :show, step))

      assert html =~ "Show Step"
    end

    test "updates step within modal", %{conn: conn, step: step} do
      {:ok, show_live, _html} = live(conn, Routes.step_show_path(conn, :show, step))

      assert show_live 
      |> element("a", "Edit") 
      |> render_click() =~ "Edit Step"

      assert_patch(show_live, Routes.step_show_path(conn, :edit, step))

      assert show_live
             |> form("#step-form", step: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#step-form", step: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_show_path(conn, :show, step))

      assert html =~ "Step updated successfully"
    end
  end
end
