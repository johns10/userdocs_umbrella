defmodule UserDocsWeb.VersionLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Projects

  @project_attrs %{base_url: "some base_url", name: "some name"}

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp first_project_id() do
    Projects.list_projects()
    |> Enum.at(0)
    |> Map.get(:id)
  end

  defp fixture(:project) do
    {:ok, project} = Projects.create_project(@project_attrs)
    project
  end
  defp fixture(:version) do
    {:ok, version} = Projects.create_version(@create_attrs)
    version
  end

  defp create_project(_) do
    project = fixture(:project)
    %{project: project}
  end

  defp create_version(_) do
    version = fixture(:version)
    %{version: version}
  end

  describe "Index" do
    setup [:create_project, :create_version]

    test "lists all versions", %{conn: conn, version: version} do
      {:ok, _index_live, html} = live(conn, Routes.version_index_path(conn, :index))

      assert html =~ "Listing Versions"
      assert html =~ version.name
    end

    test "saves new version", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live
      |> element("a", "New Version")
      |> render_click() =~ "New Version"

      assert_patch(index_live, Routes.version_index_path(conn, :new))

      assert index_live
      |> form("#version-form", version: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      version_attrs = Map.put(
        @create_attrs,
        :project_id,
        first_project_id()
      )

      {:ok, _, html} =
        index_live
        |> form("#version-form", version: version_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.version_index_path(conn, :index))

      assert html =~ "Version created successfully"
      assert html =~ "some name"
    end

    test "updates version in listing", %{conn: conn, version: version} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live |> element("#version-#{version.id} a", "Edit") |> render_click() =~
               "Edit Version"

      assert_patch(index_live, Routes.version_index_path(conn, :edit, version))

      assert index_live
      |> form("#version-form", version: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      update_attrs = Map.put(
        @update_attrs,
        :project_id,
        first_project_id()
      )

      {:ok, _, html} =
        index_live
        |> form("#version-form", version: update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.version_index_path(conn, :index))

      assert html =~ "Version updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes version in listing", %{conn: conn, version: version} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live |> element("#version-#{version.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#version-#{version.id}")
    end
  end

  describe "Show" do
    setup [:create_project, :create_version]

    test "displays version", %{conn: conn, version: version} do
      {:ok, _show_live, html} = live(conn, Routes.version_show_path(conn, :show, version))

      assert html =~ "Show Version"
      assert html =~ version.name
    end

    test "updates version within modal", %{conn: conn, version: version} do
      {:ok, show_live, _html} = live(conn, Routes.version_show_path(conn, :show, version))

      assert show_live
      |> element("a", "Edit")
      |> render_click() =~
               "Edit Version"

      assert_patch(show_live, Routes.version_show_path(conn, :edit, version))

      assert show_live
             |> form("#version-form", version: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      update_attrs = Map.put(@update_attrs, :project_id, first_project_id())

      {:ok, _, html} =
        show_live
        |> form("#version-form", version: update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.version_show_path(conn, :show, version))

      assert html =~ "Version updated successfully"
      assert html =~ "some updated name"
    end
  end
end
