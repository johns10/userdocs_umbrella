defmodule UserDocsWeb.TeamLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.ProjectsFixtures

  defp create_user(%{ password: password }), do: %{user: UsersFixtures.user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_project(%{ team: team }) do
    attrs = ProjectsFixtures.project_attrs(:default, team.id)
    { :ok, project } = UserDocs.Projects.create_project(attrs)
    %{ project: project }
  end
  defp create_version(%{ project: project, strategy: strategy }), do: %{version: ProjectsFixtures.version(project.id, strategy.id)}

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

    test "lists all teams", %{authed_conn: conn, team: team} do
      {:ok, _index_live, html} = live(conn, Routes.team_index_path(conn, :index))

      assert html =~ "Listing Teams"
      assert html =~ team.name
    end

    test "saves new team", %{authed_conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.team_index_path(conn, :index))

      assert index_live |> element("a", "New Team") |> render_click() =~ "New Team"

      assert_patch(index_live, Routes.team_index_path(conn, :new))

      assert index_live
      |> form("#team-form", team: UsersFixtures.team_attrs(:invalid))
      |> render_change() =~ "can&apos;t be blank"

      valid_attrs = UsersFixtures.team_attrs(:valid)

      {:ok, _, html} =
        index_live
        |> form("#team-form", team: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.team_index_path(conn, :index))

      assert html =~ "Team created successfully"
      assert html =~ valid_attrs.name
    end

    test "updates team in listing", %{authed_conn: conn, team: team} do
      {:ok, index_live, _html} = live(conn, Routes.team_index_path(conn, :index))

      assert index_live |> element("#edit-team-" <> to_string(team.id)) |> render_click() =~
               "Edit Team"

      assert_patch(index_live, Routes.team_index_path(conn, :edit, team))

      assert index_live
             |> form("#team-form", team: UsersFixtures.team_attrs(:invalid))
             |> render_change() =~ "can&apos;t be blank"

      valid_attrs = UsersFixtures.team_attrs(:valid)

      {:ok, _, html} =
        index_live
        |> form("#team-form", team: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.team_index_path(conn, :index))

      assert html =~ "Team updated successfully"
      assert html =~ valid_attrs.name
    end

    test "deletes team in listing", %{authed_conn: conn, team: team} do
      {:ok, index_live, _html} = live(conn, Routes.team_index_path(conn, :index))

      assert index_live |> element("#delete-team-" <>  to_string(team.id)) |> render_click()
      refute has_element?(index_live, "#team-" <> to_string(team.id))
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

    test "displays team", %{authed_conn: conn, team: team} do
      {:ok, _show_live, html} = live(conn, Routes.team_show_path(conn, :show, team))

      assert html =~ "Show Team"
      assert html =~ team.name
    end
    """
    # We don't support a form on this page yet
    test "updates team within modal", %{authed_conn: conn, team: team} do
      {:ok, show_live, _html} = live(conn, Routes.team_show_path(conn, :show, team))

      assert show_live
      |> element("a", "Edit")
      |> render_click() =~
        "Edit Team"

      assert_patch(show_live, Routes.team_show_path(conn, :edit, team))

      assert show_live
      |> form("#team-form", team: UsersFixtures.team_attrs(:invalid))
      |> render_change() =~ "can&apos;t be blank"

      valid_attrs = UsersFixtures.team_attrs(:valid)

      {:ok, _, html} =
        show_live
        |> form("#team-form", team: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.team_show_path(conn, :show, team))

      assert html =~ "Team updated successfully"
      assert html =~ valid_attrs.name
    end
    """
  end
end
