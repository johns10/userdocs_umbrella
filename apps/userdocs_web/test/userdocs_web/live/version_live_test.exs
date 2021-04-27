defmodule UserDocsWeb.VersionLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.ProjectsFixtures, as: ProjectFixtures

  defp create_user(%{ password: password }), do: %{user: UsersFixtures.user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_project(%{ team: team }) do
    attrs = ProjectFixtures.project_attrs(:default, team.id)
    { :ok, project } = UserDocs.Projects.create_project(attrs)
    %{ project: project }
  end
  defp create_version(%{ project: project, strategy: strategy }), do: %{version: ProjectFixtures.version(project.id, strategy.id)}

  defp create_password(_), do: %{ password: UUID.uuid4()}
  defp grevious_workaround(%{ conn: conn, user: user, password: password }) do
    conn = post(conn, "session", %{ user: %{ email: user.email, password: password } })
    :timer.sleep(100)
    %{ authed_conn: conn }
  end

  defp make_selections(%{ user: user, team: team, project: project, version: version }) do
    { :ok, user } = UserDocs.Users.update_user_selections(user, %{
      selected_team_id: team.id,
      selected_project_id: project.id,
      selected_version_id: version.id
    })
    %{user: user}
  end

  describe "Index" do
    setup [
      :create_password,
      :create_user,
      :create_team,
      :create_strategy,
      :create_team_user,
      :create_project,
      :create_version,
      :make_selections,
      :grevious_workaround
    ]

    test "lists all versions", %{authed_conn: conn, version: version} do
      {:ok, _index_live, html} = live(conn, Routes.version_index_path(conn, :index))

      assert html =~ "Listing Versions"
      assert html =~ version.name
    end

    test "saves new version", %{authed_conn: conn, project: project, strategy: strategy} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live
      |> element("a", "New Version")
      |> render_click() =~ "New Version"

      assert_patch(index_live, Routes.version_index_path(conn, :new))

      assert index_live
      |> form("#version-form", version: ProjectFixtures.version_attrs(:invalid, project.id, strategy.id))
      |> render_change() =~ "can&apos;t be blank"

      valid_attrs = ProjectFixtures.version_attrs(:valid, project.id, strategy.id)

      {:ok, _, html} =
        index_live
        |> form("#version-form", version: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.version_index_path(conn, :index, project.id))

      assert html =~ "Version created successfully"
      assert html =~ valid_attrs.name
    end

    test "updates version in listing", %{authed_conn: conn, project: project, version: version , strategy: strategy} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live
             |> element("#edit-version-" <> to_string(version.id))
             |> render_click() =~ "Edit Version"

      assert_patch(index_live, Routes.version_index_path(conn, :edit, version))

      assert index_live
      |> form("#version-form", version: ProjectFixtures.version_attrs(:invalid, project.id, strategy.id))
      |> render_change() =~ "can&apos;t be blank"

      valid_attrs = ProjectFixtures.version_attrs(:valid, project.id, strategy.id)

      {:ok, _, html} =
        index_live
        |> form("#version-form", version: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.version_index_path(conn, :index, project.id))

      assert html =~ "Version updated successfully"
      assert html =~ valid_attrs.name
    end

    test "deletes version in listing", %{authed_conn: conn, version: version} do
      {:ok, index_live, _html} = live(conn, Routes.version_index_path(conn, :index))

      assert index_live |> element("#delete-version-" <> to_string(version.id)) |> render_click()
      refute has_element?(index_live, "#delete-version-" <> to_string(version.id))
    end
  end

  describe "Show" do
    setup [
      :create_password,
      :create_user,
      :create_team,
      :create_strategy,
      :create_team_user,
      :create_project,
      :create_version,
      :make_selections,
      :grevious_workaround
    ]

    test "displays version", %{authed_conn: conn, version: version} do
      {:ok, _show_live, html} = live(conn, Routes.version_show_path(conn, :show, version))

      assert html =~ "Version"
      assert html =~ version.name
    end
    """
    # We don't support an edit modal on the show right now
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
    """
  end
end
