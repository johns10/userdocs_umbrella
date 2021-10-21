defmodule UserDocsWeb.PageLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Web
  alias UserDocs.ProjectsFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures

  defp create_password(_), do: %{password: UUID.uuid4()}
  defp create_user(%{password: password}), do: %{user: UsersFixtures.confirmed_user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_project(%{team: team, strategy: strategy}), do: %{project: ProjectsFixtures.project(team.id, strategy.id)}
  defp create_page(%{project: project}), do: %{page: WebFixtures.page(project.id)}

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
      :create_team_user,
      :create_strategy,
      :create_project,
      :create_page,
      :grevious_workaround,
      :make_selections,
    ]

    test "lists all pages", %{conn: conn, page: page} do
      {:ok, _index_live, html} = live(conn, Routes.page_index_path(conn, :index))

      assert html =~ "Listing Pages"
    end

    test "saves new page", %{conn: conn, project: project} do
      {:ok, index_live, _html} = live(conn, Routes.page_index_path(conn, :index))

      assert index_live |> element("a", "New Page") |> render_click() =~
               "New Page"

      assert_patch(index_live, Routes.page_index_path(conn, :new))

      assert index_live
             |> form("#page-form", page: %{name: "", project_id: nil})
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#page-form", page: WebFixtures.page_attrs(:valid, project.id))
        |> render_submit()
        |> follow_redirect(conn, Routes.page_index_path(conn, :index))

      assert html =~ "Page created successfully"
    end

    test "updates page in listing", %{conn: conn, page: page, project: project} do
      {:ok, index_live, _html} = live(conn, Routes.page_index_path(conn, :index))

      assert index_live |> element("#edit-page-#{page.id}") |> render_click() =~
               "Edit Page"

      assert_patch(index_live, Routes.page_index_path(conn, :edit, page))

      assert index_live
             |> form("#page-form", page: %{url: "", name: "", project_id: nil})
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#page-form", page: WebFixtures.page_attrs(:valid, project.id))
        |> render_submit()
        |> follow_redirect(conn, Routes.page_index_path(conn, :index))

      assert html =~ "Page updated successfully"
    end

    test "deletes page in listing", %{conn: conn, page: page} do
      {:ok, index_live, _html} = live(conn, Routes.page_index_path(conn, :index))

      assert index_live |> element("#delete-page-#{page.id}") |> render_click()
      refute has_element?(index_live, "#delete-page-#{page.id}")
    end
  end
  describe "Show" do
    setup [
      :create_password,
      :create_user,
      :create_team,
      :create_team_user,
      :create_strategy,
      :create_project,
      :create_page,
      :grevious_workaround,
      :make_selections,
    ]

    test "displays page", %{conn: conn, page: page} do
      {:ok, _show_live, html} = live(conn, Routes.page_show_path(conn, :show, page))

      assert html =~ "Show Page"
    end

    test "updates page within modal", %{conn: conn, page: page, project: project} do
      {:ok, show_live, _html} = live(conn, Routes.page_show_path(conn, :show, page))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Page"

      assert_patch(show_live, Routes.page_show_path(conn, :edit, page))

      assert show_live
             |> form("#page-form", page: %{url: "", name: ""})
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#page-form", page: WebFixtures.page_attrs(:valid, project.id))
        |> render_submit()
        |> follow_redirect(conn, Routes.page_show_path(conn, :show, page))

      assert html =~ "Page updated successfully"
    end
  end
end
