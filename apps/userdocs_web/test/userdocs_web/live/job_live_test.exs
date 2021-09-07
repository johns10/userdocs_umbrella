defmodule UserDocsWeb.JobLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Jobs
  alias UserDocs.JobsFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.ProjectsFixtures

  @create_attrs %{name: "Test"}
  @update_attrs %{name: "Test2"}
  @invalid_attrs %{name: ""}


  defp create_password(_), do: %{password: UUID.uuid4()}
  defp create_user(%{password: password}), do: %{user: UsersFixtures.confirmed_user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_job(%{team: team}), do: %{job: JobsFixtures.job(team.id)}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_project(%{team: team}), do: %{project: ProjectsFixtures.project(team.id)}
  defp grevious_workaround(%{conn: conn, user: user, password: password}) do
    conn = post(conn, "session", %{user: %{email: user.email, password: password}})
    :timer.sleep(100)
    %{conn: conn}
  end
  defp make_selections(%{user: user, team: team, project: project}) do
    {:ok, user} = UserDocs.Users.update_user_selections(user, %{
      selected_team_id: team.id,
      selected_project_id: project.id
    })
    %{user: user}
  end

  describe "Index" do
    setup [
      :create_password,
      :create_user,
      :create_team,
      :create_job,
      :create_strategy,
      :create_team_user,
      :create_project,
      :make_selections,
      :grevious_workaround,
    ]

    test "lists all jobs", %{conn: conn, job: job} do
      {:ok, _index_live, html} = live(conn, Routes.job_index_path(conn, :index))

      assert html =~ "Listing Jobs"
    end

    test "saves new job", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.job_index_path(conn, :index))

      assert index_live |> element("a", "New Job") |> render_click() =~
               "New Job"

      assert_patch(index_live, Routes.job_index_path(conn, :new))

      assert index_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#job-form", job: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.job_index_path(conn, :index))

      assert html =~ "Job created successfully"
    end

    test "updates job in listing", %{conn: conn, job: job} do
      {:ok, index_live, _html} = live(conn, Routes.job_index_path(conn, :index))

      assert index_live |> element("#edit-job-#{job.id}") |> render_click() =~
               "Edit Job"

      assert_patch(index_live, Routes.job_index_path(conn, :edit, job))

      assert index_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#job-form", job: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.job_index_path(conn, :index))

      assert html =~ "Job updated successfully"
    end

    test "deletes job in listing", %{conn: conn, job: job} do
      {:ok, index_live, _html} = live(conn, Routes.job_index_path(conn, :index))

      assert index_live |> element("#delete-job-#{job.id}") |> render_click()
      refute has_element?(index_live, "#job-#{job.id}")
    end
  end
  """
  describe "Show" do
    setup [
      :create_password,
      :create_user,
      :create_team,
      :create_job,
      :create_strategy,
      :create_team_user,
      :create_project,
      :make_selections,
      :grevious_workaround,
    ]

    test "displays job", %{conn: conn, job: job} do
      {:ok, _show_live, html} = live(conn, Routes.job_show_path(conn, :show, job))

      assert html =~ "Show Job"
    end

    test "updates job within modal", %{conn: conn, job: job} do
      {:ok, show_live, _html} = live(conn, Routes.job_show_path(conn, :show, job))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Job"

      assert_patch(show_live, Routes.job_show_path(conn, :edit, job))

      assert show_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#job-form", job: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.job_show_path(conn, :show, job))

      assert html =~ "Job updated successfully"
    end
  end
  """
end
