defmodule UserDocsWeb.ElementLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.AutomationFixtures
  alias UserDocs.Elements
  alias UserDocs.ProjectsFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures

  defp create_password(_), do: %{password: UUID.uuid4()}
  defp create_user(%{password: password}), do: %{user: UsersFixtures.confirmed_user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_project(%{team: team, strategy: strategy}), do: %{project: ProjectsFixtures.project(team.id, strategy.id)}
  defp create_process(%{project: project}), do: %{process: AutomationFixtures.process(project.id)}
  defp create_page(%{project: project}), do: %{page: WebFixtures.page(project.id)}
  defp create_element(%{page: page, strategy: strategy}), do: %{element: WebFixtures.element(page.id, strategy.id)}

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
      :create_process,
      :create_page,
      :create_element,
      :grevious_workaround,
      :make_selections,
    ]

    test "lists all elements", %{conn: conn, page: page, element: element} do
      {:ok, _index_live, html} = live(conn, Routes.element_index_path(conn, :index, page.id))

      assert html =~ "Listing Elements"
    end

    test "saves new element", %{conn: conn, page: page, strategy: strategy} do
      {:ok, index_live, _html} = live(conn, Routes.element_index_path(conn, :index, page.id))

      assert index_live |> element("a", "New Element") |> render_click() =~
               "New Element"

      assert_patch(index_live, Routes.element_index_path(conn, :new, page.id))

      assert index_live
             |> form("#element-form", element: WebFixtures.element_attrs(:invalid, page.id, strategy.id))
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#element-form", element: WebFixtures.element_attrs(:valid, page.id, strategy.id))
        |> render_submit()
        |> follow_redirect(conn, Routes.element_index_path(conn, :index, page.id))

      assert html =~ "Element created successfully"
    end

    test "updates element in listing", %{conn: conn, page: page, strategy: strategy, element: element} do
      {:ok, index_live, _html} = live(conn, Routes.element_index_path(conn, :index, page.id))

      assert index_live |> element("#edit-element-#{element.id}") |> render_click() =~
               "Edit Element"

      assert_patch(index_live, Routes.element_index_path(conn, :edit, page.id, element))

      assert index_live
             |> form("#element-form", element: WebFixtures.element_attrs(:invalid, page.id, strategy.id))
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#element-form", element: WebFixtures.element_attrs(:valid, page.id, strategy.id))
        |> render_submit()
        |> follow_redirect(conn, Routes.element_index_path(conn, :index, page.id))

      assert html =~ "Element updated successfully"
    end

    test "deletes element in listing", %{conn: conn, page: page, element: element} do
      {:ok, index_live, _html} = live(conn, Routes.element_index_path(conn, :index, page.id))

      assert index_live |> element("#delete-element-#{element.id}") |> render_click()
      refute has_element?(index_live, "#delete-element-#{element.id}")
    end
  end
end
