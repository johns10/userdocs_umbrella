defmodule UserDocsWeb.DocumentLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.UsersFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.AutomationFixtures
  alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures

  defp create_user(%{ password: password }), do: %{user: UsersFixtures.user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_project(%{ team: team }), do: %{project: ProjectsFixtures.project(team.id)}
  defp create_version(%{ project: project, strategy: strategy }), do: %{version: ProjectsFixtures.version(project.id, strategy.id)}
  defp create_process(%{ version: version }), do: %{ process: AutomationFixtures.process(version.id)}
  defp create_document(%{ project: project }), do: %{ document: DocumentFixtures.document(project.id )}

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
      :create_document,
      :make_selections,
      :grevious_workaround
    ]

    test "lists all documents", %{authed_conn: conn, document: document} do
      {:ok, _index_live, html} = live(conn, Routes.document_index_path(conn, :index))

      assert html =~ "Listing Documents"
      assert html =~ document.name
    end

    test "saves new document", %{authed_conn: conn, project: project} do
      {:ok, index_live, _html} = live(conn, Routes.document_index_path(conn, :index))

      assert index_live |> element("a", "New Document") |> render_click() =~
               "New Document"

      assert_patch(index_live, Routes.document_index_path(conn, :new))

      assert index_live
             |> form("#document-form", document: DocumentFixtures.document_attrs(:invalid, project.id))
             |> render_change() =~ "can&#39;t be blank"

      valid_attrs = DocumentFixtures.document_attrs(:valid, project.id)

      {:ok, _, html} =
        index_live
        |> form("#document-form", document: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.document_index_path(conn, :index))

      assert html =~ "Document created successfully"
      assert html =~ valid_attrs.name
    end

    test "updates document in listing", %{authed_conn: conn, document: document, project: project} do
      {:ok, index_live, _html} = live(conn, Routes.document_index_path(conn, :index))

      assert index_live |> element("#edit-document-" <> to_string(document.id)) |> render_click() =~
               "Edit Document"

      assert_patch(index_live, Routes.document_index_path(conn, :edit, document))

      assert index_live
             |> form("#document-form", document: DocumentFixtures.document_attrs(:invalid, project.id))
             |> render_change() =~ "can&#39;t be blank"

      valid_attrs = DocumentFixtures.document_attrs(:valid, project.id)

      {:ok, _, html} =
        index_live
        |> form("#document-form", document: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.document_index_path(conn, :index))

      assert html =~ "Document updated successfully"
      assert html =~ valid_attrs.name
    end

    test "deletes document in listing", %{authed_conn: conn, document: document} do
      {:ok, index_live, _html} = live(conn, Routes.document_index_path(conn, :index))

      assert index_live |> element("#delete-document-" <> to_string(document.id)) |> render_click()
      refute has_element?(index_live, "#document" <> to_string(document.id))
    end

    test "index handles standard events", %{authed_conn: conn, version: version } do
      {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :index))
      send(live.pid, {:broadcast, "update", %UserDocs.Users.User{}})
      assert live
             |> element("#version-picker-#{version.id}")
             |> render_click() =~ version.name
    end
  end
end
