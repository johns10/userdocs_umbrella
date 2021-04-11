defmodule UserDocs.JobsTest do
  use UserDocs.DataCase

  alias UserDocs.Jobs

  alias UserDocs.AutomationFixtures
  alias UserDocs.JobsFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures

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

  describe "jobs" do
    alias UserDocs.Jobs.Job

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

    test "list_job/0 returns all job instances", %{ team: team } do
      job = JobsFixtures.job(team.id)
      assert Jobs.list_jobs() == [ job ]
    end

    test "get_job!/1 returns the job with given id", %{ team: team } do
      job = JobsFixtures.job(team.id)
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job instance", %{ team: team } do
      attrs = JobsFixtures.job_attrs(:valid, team.id)
      assert {:ok, %Job{} = job} = Jobs.create_job(attrs)
      assert job.name == attrs.name
    end

    test "create_job/1 with invalid data returns error changeset", %{ team: team } do
      attrs = JobsFixtures.job_attrs(:invalid, team.id)
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(attrs)
    end

    test "update_job/2 with valid data updates the job instance", %{ team: team } do
      job = JobsFixtures.job(team.id)
      attrs = JobsFixtures.job_attrs(:valid, team.id)
      assert {:ok, %Job{} = job} = Jobs.update_job(job, attrs)
      assert job.name == attrs.name
    end

    test "update_job/2 with invalid data returns error changeset", %{ team: team } do
      job = JobsFixtures.job(team.id)
      attrs = JobsFixtures.job_attrs(:invalid, team.id)
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the step instance", %{ team: team } do
      job = JobsFixtures.job(team.id)
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = JobsFixtures.job()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end
  end
end
