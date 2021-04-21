defmodule UserDocs.Screenshot do
  use UserDocs.DataCase

  alias UserDocs.Jobs
  alias UserDocs.AutomationFixtures
  alias UserDocs.JobsFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.MediaFixtures

  defp fixture(:user), do: UsersFixtures.user()
  defp fixture(:team), do: UsersFixtures.team()
  defp fixture(:team_user, user_id, team_id), do: UsersFixtures.team_user(user_id, team_id)
  defp fixture(:project, team_id), do: ProjectsFixtures.project(team_id)
  defp fixture(:version, project_id), do: ProjectsFixtures.version(project_id)
  defp fixture(:process, version_id), do: AutomationFixtures.process(version_id)
  defp fixture(:page, version_id), do: WebFixtures.page(version_id)
  defp fixture(:strategy), do: WebFixtures.strategy()
  defp fixture(:element, page_id, strategy_id), do: WebFixtures.element(page_id, strategy_id)
  defp fixture(:annotation, page_id), do: WebFixtures.annotation(page_id)
  defp fixture(:step_types), do: AutomationFixtures.all_valid_step_types()
  defp fixture(:step, page_id, process_id, element_id, annotation_id, step_type_id) do
    step = AutomationFixtures.step(page_id, process_id, element_id, annotation_id, step_type_id)
    UserDocs.Automation.get_step!(step.id)
  end

  defp create_user(_), do: %{user: fixture(:user)}
  defp create_team(%{user: user}), do: %{team: fixture(:team)}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: fixture(:team_user, user.id, team.id)}
  defp create_project(%{team: team}), do: %{project: fixture(:project, team.id)}
  defp create_version(%{project: project}), do: %{version: fixture(:version, project.id)}
  defp create_process(%{version: version}), do: %{process: fixture(:process, version.id)}
  defp create_page(%{version: version}), do: %{page: fixture(:page, version.id)}
  defp create_strategy(_), do: %{strategy: fixture(:strategy)}
  defp create_element(%{page: page, strategy: strategy}), do: %{element: fixture(:element, page.id, strategy.id)}
  defp create_annotation(%{page: page}), do: %{annotation: fixture(:annotation, page.id)}
  defp create_step_types(_), do: %{step_types: fixture(:step_types)}
  defp create_step(%{page: page, process: process, element: element, annotation: annotation, step_types: step_types}) do
    %{step: fixture(:step, page.id, process.id, element.id, annotation.id, step_types |> Enum.at(0) |> Map.get(:id))}
  end

  defp single_white_pixel(), do: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAFiUAABYlAUlSJPAAAAAMSURBVBhXY/j//z8ABf4C/qc1gYQAAAAASUVORK5CYII="
  defp single_black_pixel(), do: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAFiUAABYlAUlSJPAAAAANSURBVBhXY8jPz/8PAATrAk3xWKD8AAAAAElFTkSuQmCC"
  defp add_element_button(), do: "iVBORw0KGgoAAAANSUhEUgAAAJEAAAAtCAYAAACu0IktAAAEOklEQVR4nO2cP2gbVxzHPy6pEU2QwCK1oGo96ExBgQoHg5DI4IJxFq8WGYQmDYGOmYRmoSlLpwyahAbjTIEUmmCoJwtBsFFBLsGnQUW0copCJJJWaHGHu5N0+hfVTz7H9PfZ9Hzv937vve/9fr93Pmkh+uPT8z/bfyMIF+UGwPfaV3zx+Y2r9kW4hvz0W80Q0S/6HyxwftX+CNeUz67aAeH6IyISlBERCcqIiARlRESCMiIiQRkRkaCMiEhQRkQkKCMiEpQREQnKiIgEZUREgjIiIkEZEZGgzJW8iZZ9mCDmNT80dQJPDmfoFeVFWkMD2rVXrBVOptvuNMg+fklugo2pNHUCx7c43vThBvRynvvPZ3Dxf8oViCjKXe/AR+9tskDKYS+mCRGA8JZzzsyR6TfR5eB8Otu+PRQJPNzddtwLYY44HImCFL71ANCu6VSWNSIu0PxRYDCljaaddq3BmyFrtrQI0GlQ/HA5ngMQ3uqlOBu9u970u9mgeNNHxNW/RC/rELLPaTBNJuMPSK0sjgzZi5jm2Aysm338OhuP1vvtLh+p9AM29neJl9SnPg1nI1HYzx0XQJfK6SEHZ12j3fsNhbB10YCAOg2ymTyBzCsqyz7bBvQF1KW4nyeQyZM9WyIyKKq5+j4goKZOIJMnkNHRwdiwR1skrWu9hoD0cp5AuQWAFtLQaLGXyZOtdc22BC+27QLSy8ZcrH7ulXWO48GeG+4VjYjLmvPg+H4OHufZa5oXdhpkM5cvIHA4EiVXl4xN6LzloAQ53vLDig83i9xZDULJXqO0z+pmTj8h/nqVasgzatS0BZAr/M7OLIUzxuZU0+tj/tJiL/Nsao2m162oechRU0MbJ9ymbkaZv9BDHvNAcGrYPbXmPTr2kVXAP+/3G6Zd+9UUx5TxHcRBEUXZse6212bBV6pTuWfcte5lP0lOJheCUxa1z+yL+tHCegpaKEE1NNT44T05YMey//7dSL837z42nodYOkFsbD//f7DjLM6JaKCgHrsJriU2wpBzIPyqMvnIH1W0PCUKhsc1fho4JKJ+QT169LRqoEUia1GYJKLwLb6cYZyvb87B3ZkJUjCLWSOyzdF0rwbrUtzfJT5H0/PGmcK6V1AP1jkWhxxZxaD5zMjCSHEAQQr3xtUQ9CIYQDL+nf3UckkYp0lge9Ucr0vldB4ppv+4I7vms9WPnzKORKLegtDi5zF1SKreIub1YCziM+5nMKKTy0cqnTDCe7NBkf6xOfUkDw8TxLyLRDYTVDcN+8UaRMYclYeZXFhjPrEeaiu9ZA0zOng1qmkrOZuRQmGjc4VdME9otlR/gQeGvbV08Ii/YPygwz/yNWrhQpwj/4AV5oCISFBGRCQoIyISlBERCcqIiARlRESCMiIiQRkRkaCMiEhQRkQkKCMiEpQREQnKiIgEZcz3ic7lRRDhwvwL9hZ6rB+bETgAAAAASUVORK5CYII="
  defp delete_button(), do: "iVBORw0KGgoAAAANSUhEUgAAAGIAAAAtCAYAAABVq763AAAAAXNSR0IArs4c6QAAAjFJREFUeJztmjFr20AYhp8kLjgmMQ0YPJRA0OJFQ1oMJpAp0KEUOnjzVuhf6Nwhc/9Atg4FbxkKXr10CAKTLFqyiFIvdXFIsTtEDiYdlNZ1rCjO2fJ9Id8zmUPvfcc9vtMdaGn3oHGFYp0MwKvtku1xPGpa339EIj6f/mQ588T2eB4tuTBk2fYglAgVIQQVIQQVIQQVIQQVIQQVIQQVIQQVIQQVIQQVIQQVIQQVIQQVIQQVIYTMYsps8aVWwEl4IghavPHM+ux32uw0O7MN0TILEjFiYtIqLr6TxXHK+IUubuNbugO4rgdDvOMT3p2mW25a7G9Nno8bXES/8wWO9op2x2OJha+IWLzfBE72xtZ123Z2wWHd50NsR8mZYO8574sr120rVF6UOXrWZqe5alBrvthfEbH8N6GDPh/rLdx6G28AkKVac9k3yDjNk9HqY4h33BqXMHWt+SNUxIj++S8+AdDh6/kwtcwsuXkgY2tKYL24iV/bHG8cXBIA2wYZ01ppI17E7UfTLar3zpjWSh8ZIipriXeMv+y/LlPNA70ubmO6rscz0x+NTXOm2H9H/DvXA73uxD9yfeMpbwFKJV7mo7agmzwxJplZcvNgafegcXW2upHyl34mN+v4zOi5uJv1XZnJfqNs/PH1/rd9M3Jhb1EilCRyYU/A1qQAEt4RCqAixKAihKAihKAihKAihKAihKAihKAihKAihKAihKAihKAihJABuDx72F/JPXRC4A9yh+TGbWibfAAAAABJRU5ErkJggg=="
  describe "screenshot" do
    alias UserDocs.Screenshots
    alias UserDocs.Media.Screenshot

    setup [
      :create_user,
      :create_team,
      :create_team_user,
      :create_project,
      :create_version,
      :create_process,
      :create_page,
      :create_strategy,
      :create_element,
      :create_annotation,
      :create_step_types,
      :create_step
    ]

    test "list_screenshots/0 returns all screenshots", %{ step: step } do
      screenshot = MediaFixtures.screenshot(step.id)
      assert Screenshots.list_screenshots() == [ screenshot ]
    end

    test "get_screenshot!/1 returns the screenshot with given id", %{ step: step } do
      screenshot = MediaFixtures.screenshot(step.id)
      assert Screenshots.get_screenshot!(screenshot.id) == screenshot
    end

    test "get_screenshot_url/1 with no screenshot returns { :nofile, _ }", %{ step: step, team: team } do
      screenshot = MediaFixtures.screenshot(step.id)
      result = Screenshots.get_screenshot_url(screenshot, team)
      assert result == { :nofile, "" }
    end

    test "get_screenshot_url/1 with a screenshot a presigned url", %{ step: step, team: team } do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base_64, single_white_pixel)
      { :ok, screenshot } = Screenshots.update_screenshot(screenshot, attrs, team)
      { status, url } = Screenshots.get_screenshot_url(screenshot, team)
      assert status == :ok
      assert String.starts_with?(url, "https://userdocs-test.s3.us-east-2.amazonaws.com")
    end

    test "create_screenshot/1 with valid data creates a screenshot", %{ step: step } do
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id)
      assert {:ok, %Screenshot{} = screenshot} = Screenshots.create_screenshot(attrs)
      assert screenshot.name == attrs.name
    end

    test "create_screenshot/1 with invalid data returns error changeset", %{ step: step } do
      attrs = JobsFixtures.step_instance_attrs(:invalid, step.id)
      assert {:error, %Ecto.Changeset{}} = Screenshots.create_screenshot(attrs)
    end

    test "update_screenshot/2 with valid data updates the screenshot", %{ step: step } do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id)
      assert {:ok, %Screenshot{} = screenshot} = Screenshots.update_screenshot(screenshot, attrs)
      assert screenshot.name == attrs.name
    end

    #TODO: Add actual file validation from aws
    test "update_screenshot/2 with no aws_screenshot creates a file on aws", %{ step: step, team: team } do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base_64, single_white_pixel)
      { :ok, screenshot } = Screenshots.update_screenshot(screenshot, attrs, team)
      assert screenshot.aws_screenshot == "screenshots/" <> to_string(screenshot.id) <> ".png"
    end

    test "update_screenshot/2 with a different file creates a provisional and diff screenshot", %{ step: step, team: team } do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base_64, single_white_pixel)
      { :ok, updated_screenshot } = Screenshots.update_screenshot(screenshot, attrs, team)
      updated_screenshot = updated_screenshot |> Map.put(:base_64, nil)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base_64, single_black_pixel)
      { :ok, final_screenshot } = Screenshots.update_screenshot(updated_screenshot, attrs, team)
      assert final_screenshot.aws_provisional_screenshot == "screenshots/" <> to_string(updated_screenshot.id) <> "-provisional.png"
      assert final_screenshot.aws_diff_screenshot == "screenshots/" <> to_string(updated_screenshot.id) <> "-diff.png"
    end

    test "update_screenshot/2 with the same file doesn't create a provisional or a diff", %{ step: step, team: team } do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base_64, single_white_pixel)
      { :ok, updated_screenshot } = Screenshots.update_screenshot(screenshot, attrs, team)
      updated_screenshot = updated_screenshot |> Map.put(:base_64, nil)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base_64, single_white_pixel)
      { :ok, final_screenshot } = Screenshots.update_screenshot(screenshot, attrs, team)
      assert final_screenshot.aws_provisional_screenshot == nil
      assert final_screenshot.aws_diff_screenshot == nil
    end

    test "apply_provisional_screenshot/1 moves the provisional to the main, and removes the provisional and the diff", %{ step: step, team: team } do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base_64, single_white_pixel())
      { :ok, screenshot } = Screenshots.update_screenshot(screenshot, attrs, team)
      screenshot = screenshot |> Map.put(:base_64, nil)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base_64, single_black_pixel())
      { :ok, screenshot } = Screenshots.update_screenshot(screenshot, attrs, team)
      final_screenshot = Screenshots.apply_provisional_screenshot(screenshot, team)
      aws_key = "screenshots/" <> to_string(screenshot.id) <> ".png"
      opts = Screenshots.aws_opts(team)
      ExAws.S3.download_file(team.aws_bucket, aws_key, "test.png") |> ExAws.request(opts)
      assert File.read!("test.png") |> Base.encode64() == single_black_pixel()
      assert final_screenshot.aws_diff_screenshot == nil
      assert final_screenshot.aws_provisional_screenshot == nil
    end

    test "update_screenshot/2 with invalid data returns error changeset", %{ step: step } do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:invalid, step.id)
      assert {:error, %Ecto.Changeset{}} = Screenshots.update_screenshot(screenshot, attrs)
      assert Screenshots.get_screenshot!(screenshot.id) == screenshot
    end

    test "delete_screenshot/1 deletes the screenshot", %{ step: step } do
      screenshot = MediaFixtures.screenshot(step.id)
      assert {:ok, %Screenshot{}} = Screenshots.delete_screenshot(screenshot)
      assert_raise Ecto.NoResultsError, fn -> Screenshots.get_screenshot!(screenshot.id) end
    end

    test "change_screenshot/1 returns a screenshot changeset", %{ step: step } do
      screenshot = MediaFixtures.screenshot(step.id)
      assert %Ecto.Changeset{} = Screenshots.change_screenshot(screenshot)
    end
  end
end
