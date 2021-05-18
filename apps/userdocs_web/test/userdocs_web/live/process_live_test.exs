defmodule UserDocsWeb.ProcessLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.AutomationFixtures
  alias UserDocs.JobsFixtures

  defp create_user(%{ password: password }), do: %{user: UsersFixtures.user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_user(%{ user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_project(%{ team: team }), do: %{project: ProjectsFixtures.project(team.id)}
  defp create_version(%{ project: project, strategy: strategy }), do: %{version: ProjectsFixtures.version(project.id, strategy.id)}
  defp create_process(%{ version: version }), do: %{ process: AutomationFixtures.process(version.id)}
  defp create_job(%{ team: team}), do: %{ job: JobsFixtures.job(team.id) }


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
      :create_process,
      :create_job,
      :make_selections,
      :grevious_workaround
    ]

    test "lists all processes", %{authed_conn: conn, process: process} do
      {:ok, _index_live, html} = live(conn, Routes.process_index_path(conn, :index))

      assert html =~ "Listing Processes"
      assert html =~ process.name
    end

    test "add process to job", %{authed_conn: conn, process: process, job: job} do
      {:ok, index_live, html} = live(conn, Routes.process_index_path(conn, :index))

      index_live
      |> element("#sidebar")
      |> render_click()

      index_live
      |> element("#process-" <> to_string(process.id) <> "-queuer")
      |> render_click()
      
      
    end
"""
    test "saves new process", %{authed_conn: conn, version: version} do
      {:ok, index_live, _html} = live(conn, Routes.process_index_path(conn, :index))

      assert index_live
      |> element("a", "New Process")
      |> render_click() =~ "New Process"

      assert_patch(index_live, Routes.process_index_path(conn, :new))

      assert index_live
      |> form("#process-form", process: AutomationFixtures.process_attrs(:invalid, version.id))
      |> render_change() =~ "can&#39;t be blank"

      valid_attrs = AutomationFixtures.process_attrs(:valid, version.id)

      {:ok, _, html} =
        index_live
        |> form("#process-form", process: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.process_index_path(conn, :index))

      assert html =~ "Process created successfully"
      assert html =~ valid_attrs.name
    end

    test "updates process in listing", %{authed_conn: conn, process: process, version: version} do
      {:ok, index_live, _html} = live(conn, Routes.process_index_path(conn, :index))

      assert index_live
      |> element("#edit-process-" <> to_string(process.id))
      |> render_click() =~ "Edit Process"

      assert_patch(index_live, Routes.process_index_path(conn, :edit, process))

      assert index_live
      |> form("#process-form", process: AutomationFixtures.process_attrs(:invalid, version.id))
      |> render_change() =~ "can&#39;t be blank"

      valid_attrs = AutomationFixtures.process_attrs(:valid, version.id)

      {:ok, _, html} =
        index_live
        |> form("#process-form", process: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.process_index_path(conn, :index))

      assert html =~ "Process updated successfully"
      assert html =~ valid_attrs.name
    end

    test "deletes process in listing", %{authed_conn: conn, process: process} do
      {:ok, index_live, _html} = live(conn, Routes.process_index_path(conn, :index))

      assert index_live |> element("#delete-process-" <> to_string(process.id)) |> render_click()
      refute has_element?(index_live, "#process-" <> to_string(process.id))
    end
    """
  end
end
