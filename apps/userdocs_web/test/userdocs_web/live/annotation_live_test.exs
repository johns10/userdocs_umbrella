defmodule UserDocsWeb.AnnotationLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Annotations
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
  defp create_annotation(%{page: page}), do: %{annotation: WebFixtures.annotation(page.id)}
  defp create_annotation_types(_), do: %{annotation_types: WebFixtures.all_valid_annotation_types()}

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
      :create_annotation,
      :create_annotation_types,
      :grevious_workaround,
      :make_selections,
    ]

    test "lists all annotation", %{conn: conn, annotation: annotation, page: page} do
      {:ok, _index_live, html} = live(conn, Routes.annotation_index_path(conn, :index, page.id))

      assert html =~ "Listing Annotation"
    end

    test "saves new annotation", %{conn: conn, page: page} do
      {:ok, index_live, _html} = live(conn, Routes.annotation_index_path(conn, :index, page.id))

      assert index_live |> element("a", "New Annotation") |> render_click() =~
               "New Annotation"

      assert_patch(index_live, Routes.annotation_index_path(conn, :new, page.id))

      assert index_live
             |> form("#annotation-form", annotation: WebFixtures.annotation_attrs(:invalid))
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#annotation-form", annotation: WebFixtures.annotation_attrs(:valid, page.id))
        |> render_submit()
        |> follow_redirect(conn, Routes.annotation_index_path(conn, :index, page.id))

      assert html =~ "Annotation created successfully"
    end

    test "updates annotation in listing", %{conn: conn, annotation: annotation, page: page} do
      {:ok, index_live, _html} = live(conn, Routes.annotation_index_path(conn, :index, page.id))

      assert index_live |> element("#edit-annotation-#{annotation.id}") |> render_click() =~
               "Edit Annotation"

      assert_patch(index_live, Routes.annotation_index_path(conn, :edit, page.id, annotation))

      assert index_live
             |> form("#annotation-form", annotation: WebFixtures.annotation_attrs(:invalid))
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#annotation-form", annotation: %{page_id: page.id})
        |> render_submit()
        |> follow_redirect(conn, Routes.annotation_index_path(conn, :index, page.id))

      assert html =~ "Annotation updated successfully"
    end

    test "deletes annotation in listing", %{conn: conn, annotation: annotation, page: page} do
      {:ok, index_live, _html} = live(conn, Routes.annotation_index_path(conn, :index, page.id))

      assert index_live |> element("#delete-annotation-#{annotation.id}") |> render_click()
      refute has_element?(index_live, "#delete-annotation-#{annotation.id}")
    end
  end
end
