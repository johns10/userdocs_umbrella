defmodule UserDocsWeb.ProjectLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Projects

  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.ProjectsFixtures

  defp create_user(%{password: password}), do: %{user: UsersFixtures.user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_project(%{team: team}), do: %{project: ProjectsFixtures.project(team.id)}
  defp create_version(%{project: project, strategy: strategy}), do: %{version: ProjectsFixtures.version(project.id, strategy.id)}

  defp create_password(_), do: %{password: UUID.uuid4()}
  defp grevious_workaround(%{conn: conn, user: user, password: password}) do
    conn = post(conn, "session", %{user: %{email: user.email, password: password}})
    :timer.sleep(100)
    %{authed_conn: conn}
  end

  defp make_selections(%{user: user, team: team, project: project, version: version}) do
    {:ok, user} = UserDocs.Users.update_user_selections(user, %{
      selected_team_id: team.id,
      selected_project_id: project.id,
      selected_version_id: version.id
    })
    %{user: user}
  end

  defp set_default_version(%{project: project, version: version}) do
    {:ok, project} = Projects.update_project(project, %{default_version_id: version.id})
    %{project: project}
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
      :grevious_workaround,
      :make_selections
    ]

    test "lists all projects", %{authed_conn: conn, project: project} do
      {:ok, _index_live, html} = live(conn, Routes.project_index_path(conn, :index))

      assert html =~ "Listing Projects"
      assert html =~ project.name
    end

    test "saves new project", %{authed_conn: conn, team: team} do
      {:ok, index_live, _html} = live(conn, Routes.project_index_path(conn, :index))

      assert index_live |> element("a", "New Project") |> render_click() =~ "New Project"

      assert_patch(index_live, Routes.project_index_path(conn, :new))

      assert index_live
             |> form("#project-form", project: ProjectsFixtures.project_attrs(:invalid, team.id))
             |> render_change() =~ "can&#39;t be blank"

      valid_attrs = ProjectsFixtures.project_attrs(:valid, team.id)

      {:ok, _, html} =
        index_live
        |> form("#project-form", project: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.project_index_path(conn, :index, team.id))

      assert html =~ "Project created successfully"
      assert html =~ valid_attrs.name
    end

    test "updates project in listing", %{authed_conn: conn, project: project, team: team} do
      {:ok, index_live, _html} = live(conn, Routes.project_index_path(conn, :index))

      assert index_live |> element("#edit-project-#{project.id}") |> render_click() =~
               "Edit Project"

      assert_patch(index_live, Routes.project_index_path(conn, :edit, project))

      assert index_live
             |> form("#project-form", project: ProjectsFixtures.project_attrs(:invalid, team.id))
             |> render_change() =~ "can&#39;t be blank"

      valid_attrs = ProjectsFixtures.project_attrs(:valid, team.id)

      {:ok, _, html} =
        index_live
        |> form("#project-form", project: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.project_index_path(conn, :index, team.id))

      assert html =~ "Project updated successfully"
      assert html =~ valid_attrs.name
    end

    test "deletes project in listing", %{authed_conn: conn, project: project} do
      {:ok, index_live, _html} = live(conn, Routes.project_index_path(conn, :index))

      assert index_live |> element("#delete-project-#{project.id}") |> render_click()
      refute has_element?(index_live, "#project-#{project.id}")
    end

    test "index handles standard events", %{authed_conn: conn, version: version} do
      {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :index))
      send(live.pid, {:broadcast, "update", %UserDocs.Users.User{}})
      assert live
             |> element("#version-picker-#{version.id}")
             |> render_click() =~ version.name
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
      :grevious_workaround,
      :set_default_version
    ]

    test "displays project", %{authed_conn: conn, project: project} do
      {:ok, _show_live, html} = live(conn, Routes.project_show_path(conn, :show, project.id))

      assert html =~ "Show Project"
      assert html =~ project.name
    end

    test "index handles standard events", %{authed_conn: conn, version: version} do
      {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :index))
      send(live.pid, {:broadcast, "update", %UserDocs.Users.User{}})
      assert live
             |> element("#version-picker-#{version.id}")
             |> render_click() =~ version.name
    end
  end
end
