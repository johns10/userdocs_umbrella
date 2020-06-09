defmodule UserDocsWeb.TeamLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Users

  @create_user_attrs %{
    email: "user@domain.com", 
    password: "password", 
    password_confirmation: "password"
  }
  @update_user_attrs %{
    email: "user@domain.com", 
    password: "password"
  }

  
  @initial_attrs %{name: "initial name", users: []}
  @create_attrs %{name: "some name", users: []}
  @update_attrs %{name: "some updated name", users: []}
  @invalid_attrs %{name: nil, users: []}

  defp first_user_id() do
    Users.list_users()
    |> Enum.at(0)
    |> Map.get(:id)
  end
  
  defp fixture(:user) do
    {:ok, user} = Users.create_user(@create_user_attrs)
    user
  end

  defp fixture(:team) do
    {:ok, team} = Users.create_team(@initial_attrs)
    team
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end

  defp create_team(_) do
    team = fixture(:team)
    %{team: team}
  end

  describe "Index" do
    setup [:create_user, :create_team]

    test "lists all teams", %{conn: conn, team: team} do
      {:ok, _index_live, html} = live(conn, Routes.team_index_path(conn, :index))

      assert html =~ "Listing Teams"
      assert html =~ team.name
    end

    test "saves new team", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.team_index_path(conn, :index))

      assert index_live 
      |> element("a", "New Team") 
      |> render_click() =~ "New Team"

      assert_patch(index_live, Routes.team_index_path(conn, :new))

      assert index_live
      |> form("#team-form", team: @invalid_attrs)
      |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#team-form", team: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.team_index_path(conn, :index))

      assert html =~ "Team created successfully"
      assert html =~ "some name"
    end

    test "updates team in listing", %{conn: conn, team: team} do
      {:ok, index_live, _html} = live(conn, Routes.team_index_path(conn, :index))

      assert index_live |> element("#team-#{team.id} a", "Edit") |> render_click() =~
               "Edit Team"

      assert_patch(index_live, Routes.team_index_path(conn, :edit, team))

      assert index_live
             |> form("#team-form", team: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#team-form", team: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.team_index_path(conn, :index))

      assert html =~ "Team updated successfully"
      assert html =~ @update_attrs.name
    end

    test "deletes team in listing", %{conn: conn, team: team} do
      {:ok, index_live, _html} = live(conn, Routes.team_index_path(conn, :index))

      assert index_live |> element("#team-#{team.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#team-#{team.id}")
    end
  end

  describe "Show" do
    setup [:create_user, :create_team]

    test "displays team", %{conn: conn, team: team} do
      {:ok, _show_live, html} = live(conn, Routes.team_show_path(conn, :show, team))

      assert html =~ "Show Team"
      assert html =~ team.name
    end
    # TODO : Figure out why this requires team[users][]
    test "updates team within modal", %{conn: conn, team: team} do
      {:ok, show_live, _html} = live(conn, Routes.team_show_path(conn, :show, team))
      
      assert show_live 
      |> element("a", "Edit") 
      |> render_click() =~
        "Edit Team"

      assert_patch(show_live, Routes.team_show_path(conn, :edit, team))

      assert show_live
      |> form("#team-form", team: @invalid_attrs)
      |> render_change() =~ 
        "can&apos;t be blank"

      team_attrs = Map.put(@update_attrs, :users, [first_user_id()])

      {:ok, _, html} =
        show_live
        |> form("#team-form", team: team_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.team_show_path(conn, :show, team))

      assert html =~ "Team updated successfully"
      assert html =~ "some updated name"
    end
  end
end
