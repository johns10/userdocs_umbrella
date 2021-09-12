defmodule UserDocs.BrowserEventsTest do
  use UserDocs.DataCase
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures

  defp fixture(:project, team_id, url) do
    {:ok, project} =
      ProjectsFixtures.project_attrs(:valid, team_id)
      |> Map.put(:base_url, url)
      |> UserDocs.Projects.create_project()
    project
  end

  defp fixture(:page, project_id, url) do
    {:ok, page} =
      WebFixtures.page_attrs(:valid, project_id)
      |> Map.put(:url, url)
      |> UserDocs.Web.create_page()
    page
  end

  defp create_user(_), do: %{user: UsersFixtures.user()}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_projects(%{team: team}), do: %{projects: [fixture(:project, team.id, "https://app.user-docs.com"), fixture(:project, team.id, "https://app.user-videos.com")]}
  defp create_pages(%{projects: [project | _]}), do: %{pages: [fixture(:page, project.id, "/projects")]}

  describe "browser_events" do
    alias UserDocs.Automation
    alias UserDocs.Automation.StepForm
    alias UserDocs.Automation.Step.BrowserEvents
    alias UserDocs.Projects
    alias UserDocs.Users.Override

    setup [
      :create_user,
      :create_team,
      :create_team_user,
      :create_projects,
      :create_pages
    ]

    test "handle_page sets the page id and page params to an existing page on a matching project for a navigate step",
    %{user: user, projects: [project | _], pages: [page | _] = pages} do
      params = %{"action" => "navigate", "page" => %{"url" => project.base_url <> page.url}}
      params = BrowserEvents.handle_page(params, Map.put(project, :pages, pages))
      assert params["page_id"] == page.id
      assert params["page"]["url"] == page.url
    end

    test "handle_page sets the page id and page params to an existing page on a matching project with an ovveride for a navigate step",
    %{projects: [project | _], pages: [page | _] = pages} do
      params = %{"action" => "navigate", "page" => %{"url" => project.base_url <> page.url}}
      params = BrowserEvents.handle_page(params, Map.put(project, :pages, pages))
      assert params["page_id"] == page.id
      assert params["page"]["url"] == page.url
    end

    test "handle_page sets the page id and page params to a new page on a matching for a navigate step",
    %{projects: [project | _], pages: [page | _] = pages} do
      params = %{"action" => "navigate", "page" => %{"url" => project.base_url <> "/nonexistentpage"}}
      params = BrowserEvents.handle_page(params, Map.put(project, :pages, pages))
      assert params["page_id"] == nil
      assert params["page"]["url"] == "/nonexistentpage"
    end

    test "handle_page sets the page id and page params to a new page on a non-matching for a navigate step",
    %{projects: [project, project_2 | _], pages: [page | _] = pages} do
      params = %{"action" => "navigate", "page" => %{"url" => project_2.base_url <> "/nonexistentpage"}}
      params = BrowserEvents.handle_page(params, Map.put(project, :pages, pages))
      assert params["page"]["url"] == "https://app.user-videos.com/nonexistentpage"
    end
  end

end
