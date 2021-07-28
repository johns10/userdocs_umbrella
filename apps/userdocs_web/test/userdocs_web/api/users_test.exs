defmodule UserDocsWeb.UserTest do
  @moduledoc false
  use UserDocsWeb.ConnCase
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures

  @user_configuration_query """
  query getUser($id: ID!) {
    user(id: $id) {
      configuration {
        strategy
        css
      }
    }
  }
  """

  defp create_password(_), do: %{password: UUID.uuid4()}
  defp create_users(%{password: password}) do
    %{
      user_1: UsersFixtures.confirmed_user(password),
      user_2: UsersFixtures.confirmed_user(password),
      user_3: UsersFixtures.confirmed_user(password)
    }
  end
  defp auth(%{conn: conn, user_1: user}), do: %{authed_conn: Pow.Plug.assign_current_user(conn, user, [])}
  defp create_teams(_) do
    %{team_1: UsersFixtures.team(), team_2: UsersFixtures.team()}
  end
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_team_users(%{user_1: user_1, user_2: user_2, user_3: user_3, team_1: team_1, team_2: team_2}) do
    %{
      team_user_1: UsersFixtures.team_user(user_1.id, team_1.id),
      team_user_2: UsersFixtures.team_user(user_2.id, team_1.id),
      team_user_3: UsersFixtures.team_user(user_3.id, team_2.id)
    }
  end
  defp create_project(%{team_1: team}) do
    attrs = ProjectsFixtures.project_attrs(:default, team.id)
    {:ok, project} = UserDocs.Projects.create_project(attrs)
    %{project: project}
  end
  defp create_version(%{project: project, strategy: strategy}), do: %{version: ProjectsFixtures.version(project.id, strategy.id)}
  defp make_selections(%{user_1: user, team_1: team, project: project, version: version}) do
    {:ok, user} = UserDocs.Users.update_user_selections(user, %{
      selected_team_id: team.id,
      selected_project_id: project.id,
      selected_version_id: version.id
   })
    %{user: user}
  end

  describe "User" do
    setup [
      :create_password,
      :create_users,
      :auth,
      :create_teams,
      :create_strategy,
      :create_team_users,
      :create_project,
      :create_version,
      :make_selections
    ]

    test "query: user can query itself", %{authed_conn: conn, user_1: user} do
      conn =
        post(conn, "/api", %{
          "query" => @user_configuration_query,
          "variables" => %{id: user.id}
        })

      assert json_response(conn, 200) == %{
        "data" => %{"user" => %{"configuration" => %{"css" => "{test: value}", "strategy" => "css"}}}
      }
    end

    test "query: user can't query other users", %{authed_conn: conn, user_2: user} do
      conn =
        post(conn, "/api", %{
          "query" => @user_configuration_query,
          "variables" => %{id: user.id}
        })

      assert json_response(conn, 200) == %{
        "data" => %{"user" => nil},
        "errors" => [%{"locations" => [%{"column" => 3, "line" => 2}], "message" => "Unauthorized", "path" => ["user"], "status" => 401}]
      }
    end
  end
end
