defmodule UserDocsWeb.ContentLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.JobsFixtures, as: JobFixtures
  alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures

  defp create_user(%{ password: password }), do: %{user: UsersFixtures.user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_project(%{ team: team }), do: %{project: ProjectsFixtures.project(team.id)}
  defp create_version(%{ project: project, strategy: strategy }), do: %{version: ProjectsFixtures.version(project.id, strategy.id)}
  defp create_content(%{ team: team }), do: %{ content: DocumentFixtures.content(team.id)}
  defp create_job(%{ team: team }), do: %{ job: JobFixtures.job(team.id) }

  defp setup_session(%{ conn: conn, user: user }) do
    opts = Pow.Plug.Session.init(otp_app: :userdocs_web)
    conn =
      conn
      |> Plug.Test.init_test_session(%{ current_user: user })
      |> Pow.Plug.Session.call(opts)
      |> Pow.Plug.Session.do_create(user, opts)

    :timer.sleep(100)

    %{ authed_conn: conn }
  end

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
      :create_content,
      :create_job,
      :make_selections,
      :grevious_workaround
    ]
    defp invalid_attrs(team_id), do: DocumentFixtures.content_attrs(:invalid, team_id)
    defp valid_attrs(team_id), do: DocumentFixtures.content_attrs(:valid, team_id)

    test "lists all content", %{ authed_conn: conn, content: content } do
      {:ok, _index_live, html} = live(conn, Routes.content_index_path(conn, :index))

      assert html =~ "Listing Content"
      assert html =~ content.name
    end

    test "saves new content", %{authed_conn: conn, team: team} do
      {:ok, index_live, _html} = live(conn, Routes.content_index_path(conn, :index))

      assert index_live |> element("a", "New Content") |> render_click() =~
               "New Content"

      assert_patch(index_live, Routes.content_index_path(conn, :new, team.id))

      assert index_live
             |> form("#content-form", content: invalid_attrs(team.id))
             |> render_change() =~ "can&#39;t be blank"

      valid_attrs = valid_attrs(team.id)

      {:ok, _, html} =
        index_live
        |> form("#content-form", content: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_index_path(conn, :index, team.id))

      assert html =~ "Content created successfully"
      assert html =~ valid_attrs.name
    end

    test "updates content in listing", %{ authed_conn: conn, content: content, team: team } do
      {:ok, index_live, _html} = live(conn, Routes.content_index_path(conn, :index))

      assert index_live |> element("#edit-content-" <> to_string(content.id)) |> render_click() =~
               "Edit Content"

      assert_patch(index_live, Routes.content_index_path(conn, :edit, team.id, content.id))

      assert index_live
             |> form("#content-form", content: invalid_attrs(team.id))
             |> render_change() =~ "can&#39;t be blank"

      valid_attrs = valid_attrs(team.id)

      html =
        index_live
        |> form("#content-form", content: valid_attrs)
        |> render_submit()

      assert html =~ "Edit Content"
    end

    test "deletes content in listing", %{authed_conn: conn, content: content} do
      {:ok, index_live, _html} = live(conn, Routes.content_index_path(conn, :index))

      assert index_live |> element("#delete-content-" <> to_string(content.id)) |> render_click()
      refute has_element?(index_live, "#content-" <> to_string(content.id))
    end

    test "index handles standard events", %{authed_conn: conn, version: version } do
      {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :index))
      send(live.pid, {:broadcast, "update", %UserDocs.Users.User{}})
      assert live
             |> element("#version-picker-#{version.id}")
             |> render_click() =~ version.name
    end
  end
  """
  Show is currently unused
  describe "Show" do
    setup [
      :create_password,
      :create_user,
      :create_team,
      :create_strategy,
      :create_team_user,
      :create_project,
      :create_version,
      :create_content,
      :create_job,
      :make_selections,
      :grevious_workaround
    ]

    test "displays content", %{authed_conn: conn, content: content} do
      {:ok, _show_live, html} = live(conn, Routes.content_show_path(conn, :show, content))

      assert html =~ "Show Content"
      assert html =~ content.name
    end

    test "updates content within modal", %{authed_conn: conn, content: content} do
      {:ok, show_live, _html} = live(conn, Routes.content_show_path(conn, :show, content))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Content"

      assert_patch(show_live, Routes.content_show_path(conn, :edit, content))

      assert show_live
             |> form("#content-form", content: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#content-form", content: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_show_path(conn, :show, content))

      assert html =~ "Content updated successfully"
      assert html =~ "some updated description"
    end
  end
  """
end
