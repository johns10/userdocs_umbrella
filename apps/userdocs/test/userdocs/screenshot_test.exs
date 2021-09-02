defmodule UserDocs.Screenshot do
  use UserDocs.DataCase

  alias UserDocs.AutomationFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.MediaFixtures

  defp fixture(:user), do: UsersFixtures.user()
  defp fixture(:team), do: UsersFixtures.team()
  defp fixture(:strategy), do: WebFixtures.strategy()
  defp fixture(:step_types), do: AutomationFixtures.all_valid_step_types()


  defp fixture(:project, team_id), do: ProjectsFixtures.project(team_id)
  defp fixture(:process, project_id), do: AutomationFixtures.process(project_id)
  defp fixture(:page, project_id), do: WebFixtures.page(project_id)
  defp fixture(:annotation, page_id), do: WebFixtures.annotation(page_id)

  defp fixture(:team_user, user_id, team_id), do: UsersFixtures.team_user(user_id, team_id)
  defp fixture(:element, page_id, strategy_id), do: WebFixtures.element(page_id, strategy_id)

  defp fixture(:step, page_id, process_id, element_id, annotation_id, step_type_id) do
    step = AutomationFixtures.step(page_id, process_id, element_id, annotation_id, step_type_id)
    UserDocs.Automation.get_step!(step.id)
  end

  defp create_user(_), do: %{user: fixture(:user)}
  defp create_team(_), do: %{team: fixture(:team)}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: fixture(:team_user, user.id, team.id)}
  defp create_project(%{team: team}), do: %{project: fixture(:project, team.id)}
  defp create_process(%{project: project}), do: %{process: fixture(:process, project.id)}
  defp create_page(%{project: project}), do: %{page: fixture(:page, project.id)}
  defp create_strategy(_), do: %{strategy: fixture(:strategy)}
  defp create_element(%{page: page, strategy: strategy}), do: %{element: fixture(:element, page.id, strategy.id)}
  defp create_annotation(%{page: page}), do: %{annotation: fixture(:annotation, page.id)}
  defp create_step_types(_), do: %{step_types: fixture(:step_types)}
  defp create_step(%{page: page, process: process, element: element, annotation: annotation, step_types: step_types}) do
    %{step: fixture(:step, page.id, process.id, element.id, annotation.id, step_types |> Enum.at(0) |> Map.get(:id))}
  end

  defp single_white_pixel(), do: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAFiUAABYlAUlSJPAAAAAMSURBVBhXY/j//z8ABf4C/qc1gYQAAAAASUVORK5CYII="
  defp single_black_pixel(), do: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAFiUAABYlAUlSJPAAAAANSURBVBhXY8jPz/8PAATrAk3xWKD8AAAAAElFTkSuQmCC"
  defp two_white_pixels(), do: "iVBORw0KGgoAAAANSUhEUgAAAAIAAAABCAIAAAB7QOjdAAABhWlDQ1BJQ0MgcHJvZmlsZQAAKJF9kT1Iw0AcxV9TtSoVhXYQUchQnSyIijhqFYpQIdQKrTqYXPohNGlIUlwcBdeCgx+LVQcXZ10dXAVB8APEzc1J0UVK/F9SaBHrwXE/3t173L0DhGqRaVbbGKDptpmMx8R0ZkUMvKIDXQihD0Mys4xZSUqg5fi6h4+vd1Ge1frcn6NHzVoM8InEM8wwbeJ14qlN2+C8TxxmBVklPiceNemCxI9cVzx+45x3WeCZYTOVnCMOE4v5JlaamBVMjXiSOKJqOuULaY9VzluctWKZ1e/JXxjM6stLXKc5iDgWsAgJIhSUsYEibERp1UmxkKT9WAv/gOuXyKWQawOMHPMoQYPs+sH/4He3Vm5i3EsKxoD2F8f5GAYCu0Ct4jjfx45TOwH8z8CV3vCXqsD0J+mVhhY5Anq3gYvrhqbsAZc7QP+TIZuyK/lpCrkc8H5G35QBQrdA96rXW30fpw9AirpK3AAHh8BInrLXWry7s7m3f8/U+/sBMgtyjVZNXqEAAAAJcEhZcwAALiMAAC4jAXilP3YAAAAHdElNRQflBgkTEgFphsfXAAAAGXRFWHRDb21tZW50AENyZWF0ZWQgd2l0aCBHSU1QV4EOFwAAAA9JREFUCNdj/P//PwMDAwAO/wL/sBiIKQAAAABJRU5ErkJggg=="
  def aws_opts(team) do
    [
      region: team.aws_region,
      access_key_id: team.aws_access_key_id,
      secret_access_key: team.aws_secret_access_key
    ]
  end

  describe "screenshot" do
    alias UserDocs.Screenshots
    alias UserDocs.Media.Screenshot

    setup [
      :create_user,
      :create_team,
      :create_team_user,
      :create_project,
      :create_process,
      :create_page,
      :create_strategy,
      :create_element,
      :create_annotation,
      :create_step_types,
      :create_step
    ]

    def score_uploaded_single_white_screenshot(aws_path, team) do
      downloaded = "./test/support/downloads/downloaded_single_white_pixel.png"
      original = "./test/support/fixtures/single_white_pixel.png"
      diff = "./test/support/downloads/diff.png"
      ExAws.S3.download_file(team.aws_bucket, aws_path, downloaded) |> ExAws.request(aws_opts(team))
      %{score: score} = Screenshots.score_files(%{original: original, updated: downloaded, diff: diff})
      #File.rm(downloaded)
      #File.rm(diff)
      score
    end
    def score_uploaded_single_black_screenshot(aws_path, team) do
      downloaded = "./test/support/downloads/downloaded_single_black_pixel.png"
      original = "./test/support/fixtures/single_black_pixel.png"
      diff = "./test/support/downloads/diff.png"
      ExAws.S3.download_file(team.aws_bucket, aws_path, downloaded) |> ExAws.request(aws_opts(team))
      %{score: score} = Screenshots.score_files(%{original: original, updated: downloaded, diff: diff})
      #File.rm(downloaded)
      #File.rm(diff)
      score
    end
    def score_uploaded_diff(aws_path, team) do
      downloaded = "./test/support/downloads/downloaded_diff.png"
      original = "./test/support/fixtures/diff.png"
      diff = "./test/support/downloads/diff.png"
      ExAws.S3.download_file(team.aws_bucket, aws_path, downloaded) |> ExAws.request(aws_opts(team))
      %{score: score} = Screenshots.score_files(%{original: original, updated: downloaded, diff: diff})
      #File.rm(downloaded)
      #File.rm(diff)
      score
    end

    test "list_screenshots/0 returns all screenshots", %{step: step} do
      screenshot = MediaFixtures.screenshot(step.id)
      assert Screenshots.list_screenshots() == [screenshot]
    end

    test "get_screenshot!/1 returns the screenshot with given id", %{step: step} do
      screenshot = MediaFixtures.screenshot(step.id)
      assert Screenshots.get_screenshot!(screenshot.id) == screenshot
    end

    test "get_screenshot_url/1 with no screenshot returns {:nofile, _}", %{step: step, team: team} do
      screenshot = MediaFixtures.screenshot(step.id)
      result = Screenshots.get_screenshot_url(screenshot, team)
      assert result == {:nofile, ""}
    end

    test "get_screenshot_url/1 with a screenshot a presigned url", %{step: step, team: team} do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_white_pixel())
      {:ok, screenshot} = Screenshots.update_screenshot(screenshot, attrs, team)
      {status, url} = Screenshots.get_screenshot_url(screenshot, team)
      assert status == :ok
      assert String.starts_with?(url, "https://userdocs-test.s3.us-east-2.amazonaws.com")
    end

    test "create_screenshot/1 with valid data creates a screenshot", %{step: step} do
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id)
      assert {:ok, %Screenshot{} = screenshot} = Screenshots.create_screenshot(attrs)
      assert screenshot.name == attrs.name
    end

    test "create_screenshot/1 with invalid data returns error changeset", %{step: step} do
      _attrs = MediaFixtures.screenshot_attrs(:invalid, step.id)
      #assert {:error, %Ecto.Changeset{}} = Screenshots.create_screenshot(attrs) # No such thing as invalid attrs atm
    end

    test "create_screenshot/1 with a base64 string creates a screenshot named with an id", %{team: team, step: step} do
      attrs = MediaFixtures.screenshot_attrs(:nameless, step.id, single_white_pixel())
      assert {:ok, %Screenshot{} = screenshot} = Screenshots.create_screenshot(attrs)
      score = score_uploaded_single_white_screenshot(screenshot.aws_screenshot, team)
      "screenshots/" <> file_name = screenshot.aws_screenshot

      assert String.slice(file_name, 0..-5) == to_string(screenshot.id)
      assert score == "inf"
    end

    test "bypassing the default create_screenshot (as we would in cast_assoc from step) results in a screenshot named with a uuid", %{team: team, step: step} do
      attrs = MediaFixtures.screenshot_attrs(:nameless, step.id, single_white_pixel())
      {:ok, screenshot} = %Screenshot{} |> Screenshot.changeset(attrs) |> UserDocs.Repo.insert()
      score = score_uploaded_single_white_screenshot(screenshot.aws_screenshot, team)
      file_name = Screenshots.unpath(screenshot.aws_screenshot)
      {status, _} = file_name |> String.slice(0..-5) |> UUID.info()
      assert status == :ok
      assert score == "inf"
    end

    test "updating a screenshot created with a uuid name, renames the file in the struct, and on aws to the id of the screenshot", %{team: team, step: step} do
      attrs = MediaFixtures.screenshot_attrs(:nameless, step.id, single_white_pixel())
      {:ok, screenshot} = %Screenshot{} |> Screenshot.changeset(attrs) |> UserDocs.Repo.insert()
      attrs = MediaFixtures.screenshot_attrs(:nameless, step.id, single_white_pixel())
      {:ok, screenshot} = screenshot |> Screenshots.update_screenshot(attrs)
      file_name = Screenshots.unpath(screenshot.aws_screenshot)
      score = score_uploaded_single_white_screenshot("screenshots/" <> to_string(screenshot.id) <> ".png", team)

      assert file_name |> String.slice(0..-5) == screenshot.id |> to_string()
      assert score == "inf"
    end

    test "updating a screenshot (created with a uuid name, renamed to an id) with an explicitn name does the right thing", %{team: team, step: step} do
      attrs = MediaFixtures.screenshot_attrs(:nameless, step.id, single_white_pixel())
      {:ok, screenshot} = %Screenshot{} |> Screenshot.changeset(attrs) |> UserDocs.Repo.insert()
      attrs = MediaFixtures.screenshot_attrs(:nameless, step.id, single_white_pixel())
      {:ok, screenshot} = screenshot |> Screenshots.update_screenshot(attrs)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_white_pixel())
      {:ok, screenshot} = screenshot |> Screenshots.update_screenshot(attrs)
      file_name = Screenshots.unpath(screenshot.aws_screenshot)
      score = score_uploaded_single_white_screenshot("screenshots/" <> to_string(screenshot.name) <> ".png", team)

      assert file_name |> String.slice(0..-5) == screenshot.name |> to_string()
      assert score == "inf"
    end

    test "update_screenshot/2 with valid data updates the screenshot", %{step: step} do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id)
      assert {:ok, %Screenshot{} = screenshot} = Screenshots.update_screenshot(screenshot, attrs)
      assert screenshot.name == attrs.name
    end

    test "update_screenshot/2 with no aws_screenshot creates a file on aws", %{step: step, team: team} do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_white_pixel())
      {:ok, screenshot} = Screenshots.update_screenshot(screenshot, attrs, team)
      score = score_uploaded_single_white_screenshot(screenshot.aws_screenshot, team)
      assert score == "inf"
      assert screenshot.aws_screenshot
    end

    test "file_name/1 is the name of the screenshot when it has one", %{step: step} do
      changeset = MediaFixtures.screenshot(step.id) |> Screenshots.change_screenshot(%{})
      assert Screenshots.file_name(changeset, :production) == changeset.data.name <> ".png"
    end

    test "file_name/1 is the id of the screenshot when it has no name", %{step: step} do
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.delete(:name)
      {:ok, screenshot} = Screenshots.create_screenshot(attrs)
      changeset = screenshot |> Screenshots.change_screenshot(%{})
      assert Screenshots.file_name(changeset, :production) == to_string(screenshot.id) <> ".png"
    end

    test "file_name/1 is a uuid when it has no name nor id", %{step: step} do
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.delete(:name)
      changeset = Screenshots.change_screenshot(%Screenshot{}, attrs)
      file_name = Screenshots.file_name(changeset, :production)
      name = file_name |> String.slice(0..-5)
      {status, _} = UUID.info(name)
      assert status == :ok
    end

    test "update_screenshot/2 with a different file creates a provisional and diff screenshot", %{step: step, team: team} do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_white_pixel())
      {:ok, updated_screenshot} = Screenshots.update_screenshot(screenshot, attrs, team)
      updated_screenshot = updated_screenshot |> Map.put(:base64, nil)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_black_pixel())
      {:ok, final_screenshot} = Screenshots.update_screenshot(updated_screenshot, attrs, team)

      provisional_score = score_uploaded_single_black_screenshot(final_screenshot.aws_provisional_screenshot, team)
      diff_score = score_uploaded_diff(final_screenshot.aws_diff_screenshot, team)

      assert final_screenshot.aws_provisional_screenshot == "screenshots/" <> final_screenshot.name <> "-provisional.png"
      assert final_screenshot.aws_diff_screenshot == "screenshots/" <> final_screenshot.name <> "-diff.png"
      assert provisional_score == "inf"
      assert diff_score == "inf"
    end

    test "update_screenshot/2 with the same file doesn't create a provisional or a diff", %{step: step, team: team} do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_white_pixel())
      {:ok, _updated_screenshot} = Screenshots.update_screenshot(screenshot, attrs, team)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_white_pixel())
      {:ok, final_screenshot} = Screenshots.update_screenshot(screenshot, attrs, team)
      assert final_screenshot.aws_provisional_screenshot == nil
      assert final_screenshot.aws_diff_screenshot == nil
    end

    test "apply_provisional_screenshot/1 moves the provisional to the main, and removes the provisional and the diff", %{step: step, team: team} do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_white_pixel())
      {:ok, screenshot} = Screenshots.update_screenshot(screenshot, attrs, team)
      screenshot = screenshot |> Map.put(:base64, nil)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_black_pixel())
      {:ok, screenshot} = Screenshots.update_screenshot(screenshot, attrs, team)
      final_screenshot = Screenshots.apply_provisional_screenshot(screenshot, team)
      _aws_key = "screenshots/" <> to_string(screenshot.id) <> ".png"
      opts = Screenshots.aws_opts(team)
      {:ok, _} = ExAws.S3.download_file(team.aws_bucket, final_screenshot.aws_screenshot, "test.png") |> ExAws.request(opts)
      assert File.read!("test.png") |> Base.encode64() == single_black_pixel()
      assert final_screenshot.aws_diff_screenshot == nil
      assert final_screenshot.aws_provisional_screenshot == nil
      File.rm("test.png")
    end

    test "update_screenshot/2 with invalid data returns error changeset", %{step: step} do
      screenshot = MediaFixtures.screenshot(step.id)
      _attrs = MediaFixtures.screenshot_attrs(:invalid, step.id)
      # assert {:error, %Ecto.Changeset{}} = Screenshots.update_screenshot(screenshot, attrs) # No such thing
      assert Screenshots.get_screenshot!(screenshot.id) == screenshot
    end

    test "delete_screenshot/1 deletes the screenshot", %{step: step} do
      screenshot = MediaFixtures.screenshot(step.id)
      assert {:ok, %Screenshot{}} = Screenshots.delete_screenshot(screenshot)
      assert_raise Ecto.NoResultsError, fn -> Screenshots.get_screenshot!(screenshot.id) end
    end

    test "change_screenshot/1 returns a screenshot changeset", %{step: step} do
      screenshot = MediaFixtures.screenshot(step.id)
      assert %Ecto.Changeset{} = Screenshots.change_screenshot(screenshot)
    end

    test "updating a screenshot with a differently sized image creates a provisional, but not diff", %{team: team, step: step} do
      screenshot = MediaFixtures.screenshot(step.id)
      attrs = MediaFixtures.screenshot_attrs(:valid, step.id) |> Map.put(:base64, single_white_pixel()) |> Map.put(:name, "Test")
      {:ok, screenshot} = Screenshots.update_screenshot(screenshot, attrs, team)
      attrs_two = %{base64: two_white_pixels()}
      {:ok, screenshot} = Screenshots.update_screenshot(screenshot, attrs_two, team)
      assert screenshot.aws_diff_screenshot == nil
      assert screenshot.aws_provisional_screenshot == "screenshots/Test-provisional.png"
      assert screenshot.aws_screenshot == "screenshots/Test.png"
    end
  end
end
