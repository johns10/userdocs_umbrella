defmodule UserDocsWeb.ProcessLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Automation
  alias UserDocs.Projects

  @create_version_attrs %{name: "version name"}

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp first_version_id() do
    Projects.list_versions()
    |> Enum.at(0)
    |> Map.get(:id)
  end

  defp fixture(:version) do
    {:ok, version} = Projects.create_version(@create_version_attrs)
    version
  end
  defp fixture(:process) do
    {:ok, process} = Automation.create_process(@create_attrs)
    process
  end

  defp create_version(_) do
    version = fixture(:version)
    %{version: version}
  end

  defp create_process(_) do
    process = fixture(:process)
    %{process: process}
  end

  describe "Index" do
    setup [:create_version, :create_process]

    test "lists all processes", %{conn: conn, process: process} do
      {:ok, _index_live, html} = live(conn, Routes.process_index_path(conn, :index))

      assert html =~ "Listing Processes"
      assert html =~ process.name
    end

    test "saves new process", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.process_index_path(conn, :index))

      assert index_live
      |> element("a", "New Process")
      |> render_click() =~ "New Process"

      assert_patch(index_live, Routes.process_index_path(conn, :new))

      assert index_live
      |> form("#process-new-form", process: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      create_attrs = Map.put(
        @create_attrs,
        :version_id,
        first_version_id()
      )

      {:ok, _, html} =
        index_live
        |> form("#process-new-form", process: create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.process_index_path(conn, :index))

      assert html =~ "Process created successfully"
      assert html =~ "some name"
    end

    test "updates process in listing", %{conn: conn, process: process} do
      {:ok, index_live, _html} = live(conn, Routes.process_index_path(conn, :index))

      assert index_live
      |> element("#process-#{process.id} a", "Edit")
      |> render_click() =~ "Edit Process"

      assert_patch(index_live, Routes.process_index_path(conn, :edit, process))

      assert index_live
      |> form("#process-#{process.id}-form", process: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      update_attrs = Map.put(
        @update_attrs,
        :version_id,
        first_version_id()
      )

      {:ok, _, html} =
        index_live
        |> form("#process-#{process.id}-form", process: update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.process_index_path(conn, :index))

      assert html =~ "Process updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes process in listing", %{conn: conn, process: process} do
      {:ok, index_live, _html} = live(conn, Routes.process_index_path(conn, :index))

      assert index_live |> element("#process-#{process.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#process-#{process.id}")
    end
  end

  describe "Show" do
    setup [:create_version, :create_process]

    test "displays process", %{conn: conn, process: process} do
      {:ok, _show_live, html} = live(conn, Routes.process_show_path(conn, :show, process))

      assert html =~ "Show Process"
      assert html =~ process.name
    end

    test "updates process within modal", %{conn: conn, process: process} do
      {:ok, show_live, _html} = live(conn, Routes.process_show_path(conn, :show, process))

      assert show_live
      |> element("a", "Edit")
      |> render_click() =~ "Edit Process"

      assert_patch(show_live, Routes.process_show_path(conn, :edit, process))

      assert show_live
      |> form("#process-#{process.id}-form", process: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      update_attrs = Map.put(
        @update_attrs,
        :version_id,
        first_version_id()
      )

      {:ok, _, html} =
        show_live
        |> form("##process-#{process.id}-form", process: update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.process_show_path(conn, :show, process))

      assert html =~ "Process updated successfully"
      assert html =~ "some updated name"
    end
  end
end
