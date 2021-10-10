defmodule UserDocsWeb.UserLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.ProjectsFixtures

  defp create_user(%{password: password}), do: %{user: UsersFixtures.confirmed_user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_project(%{team: team, strategy: strategy}) do
    attrs = ProjectsFixtures.project_attrs(:default, team.id, strategy.id)
    {:ok, project} = UserDocs.Projects.create_project(attrs)
    %{project: project}
  end
  defp create_password(_), do: %{password: UUID.uuid4()}
  defp grevious_workaround(%{conn: conn, user: user, password: password}) do
    conn = post(conn, "session", %{user: %{email: user.email, password: password}})
    :timer.sleep(100)
    %{authed_conn: conn}
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
      :create_strategy,
      :create_team_user,
      :create_project,
      :make_selections,
      :grevious_workaround
    ]

    test "lists all users", %{authed_conn: conn, user: user} do
      {:ok, _index_live, html} = live(conn, Routes.user_index_path(conn, :index))

      assert html =~ "Listing Users"
      assert html =~ user.email
    end

    test "saves new user", %{authed_conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))

      assert index_live |> element("a", "New User") |> render_click() =~ "New User"

      assert_patch(index_live, Routes.user_index_path(conn, :new))

      valid_attrs = UsersFixtures.user_attrs(:valid)

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.user_index_path(conn, :index))

      assert html =~ "User created successfully"
      assert html =~ valid_attrs.email
    end

    test "updates user in listing", %{authed_conn: conn, user: user, password: password, project: project} do
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))

      assert index_live |> element("#edit-user-" <> to_string(user.id), "Edit") |> render_click() =~
               "Edit User"

      assert_patch(index_live, Routes.user_index_path(conn, :edit, user))

      valid_attrs =
        UsersFixtures.user_attrs(:valid)
        |> Map.put(:current_password, password)

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.user_index_path(conn, :index))

      assert html =~ "User updated successfully"
      # assert html =~ valid_attrs.email # TODO: Improve assertion, confirmation broke this
    end

    test "deletes user in listing", %{authed_conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))

      assert index_live |> element("#delete-user-" <> to_string(user.id), "Delete") |> render_click()
      refute has_element?(index_live, "#user-" <> to_string(user.id))
    end

    test "index handles standard events", %{authed_conn: conn, team: team, user: user, project: project} do
      {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :index))
      send(live.pid, {:broadcast, "update", %UserDocs.Users.User{}})
      assert live
             |> element("#project-picker-" <> to_string(project.id))
             |> render_click() =~ project.name
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
      :make_selections,
      :grevious_workaround
    ]

    test "displays user", %{authed_conn: conn, user: user} do
      {:ok, show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "Show User"
      assert html =~ user.email
    end

    test "updates user within modal", %{authed_conn: conn, user: user, password: password} do
      {:ok, show_live, _html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert show_live |> element("a", "Edit") |> render_click() =~ "Edit User"

      assert_patch(show_live, Routes.user_show_path(conn, :edit, user))

      valid_attrs = UsersFixtures.user_attrs(:valid) |> Map.put(:current_password, password)

      {:ok, _, html} =
        show_live
        |> form("#user-form", user: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "User updated successfully"
      # assert html =~ valid_attrs.email # TODO: Improve assertion
    end

    test "updates user options in listing", %{authed_conn: conn, user: user, password: password, project: project} do
      {:ok, show_live, _html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert show_live |> element("#user-options") |> render_click() =~ "User Options"

      assert_patch(show_live, Routes.user_show_path(conn, :options, user))

      show_live |> element("#add-override") |> render_click()

      overrides = %{"0": %{project_id: project.id, url: "https://www.google.com/"}}

      valid_attrs =
        UsersFixtures.user_attrs(:options)
        |> Map.put(:overrides, overrides)

      {:ok, _, html} =
        show_live
        |> form("#user-form", user: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "User updated successfully"
      # assert html =~ valid_attrs.email # TODO: Improve assertion, confirmation broke this
    end

    test "show handles standard events", %{authed_conn: conn, team: team, user: user, project: project} do
      {:ok, show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))
      send(show_live.pid, {:broadcast, "update", %UserDocs.Users.User{}})
      assert show_live
             |> element("#project-picker-" <> to_string(project.id))
             |> render_click() =~ project.name
    end

  end
end
