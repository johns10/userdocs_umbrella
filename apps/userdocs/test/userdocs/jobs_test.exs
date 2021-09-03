defmodule UserDocs.JobsTest do
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
  defp fixture(:step_types), do: AutomationFixtures.all_valid_step_types()
  defp fixture(:strategy), do: WebFixtures.strategy()

  defp fixture(:project, team_id), do: ProjectsFixtures.project(team_id)
  defp fixture(:process, project_id), do: AutomationFixtures.process(project_id)
  defp fixture(:page, project_id), do: WebFixtures.page(project_id)
  defp fixture(:annotation, page_id), do: WebFixtures.annotation(page_id)
  defp fixture(:screenshot, step_id), do: MediaFixtures.screenshot(step_id)

  defp fixture(:element, page_id, strategy_id), do: WebFixtures.element(page_id, strategy_id)
  defp fixture(:team_user, user_id, team_id), do: UsersFixtures.team_user(user_id, team_id)

  defp fixture(:step, page_id, process_id, element_id, annotation_id, step_type_id), do: AutomationFixtures.step(page_id, process_id, element_id, annotation_id, step_type_id)

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
    %{step_id: fixture(:step, page.id, process.id, element.id, annotation.id, step_types |> Enum.at(0) |> Map.get(:id)) |> Map.get(:id)}
  end
  defp create_screenshot(%{step_id: step_id}), do: %{screenshot: fixture(:screenshot, step_id)}
  defp query_step(%{step_id: step_id}), do: %{step: UserDocs.Automation.get_step!(step_id)}

  describe "jobs" do
    alias UserDocs.Jobs.Job
    alias UserDocs.Jobs.JobStep
    alias UserDocs.Jobs.JobProcess

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
      :create_step,
      :create_screenshot,
      :query_step
    ]

    test "list_job/0 returns all job instances", %{team: team} do
      job = JobsFixtures.job(team.id)
      [ result_job ] = Jobs.list_jobs() # BULLSHIT, remove
      assert job == result_job
    end

    test "get_job!/1 returns the job with given id", %{team: team} do
      job = JobsFixtures.job(team.id)
      assert Jobs.get_job!(job.id) == job
    end

    test "get_job!/1 returns the preloaded job with given id", %{process: process, team: team} do
      job = JobsFixtures.job(team.id)
      process_instance_one = JobsFixtures.process_instance(process.id)
      process_instance_two = JobsFixtures.process_instance(process.id)

      {:ok, _job_process_one} = Jobs.create_job_process(job, process.id, process_instance_one.id)
      {:ok, _job_process_two} = Jobs.create_job_process(job, process.id, process_instance_two.id)

      job = Jobs.get_job!(job.id, %{preloads: [ steps: true, processes: true, last_job_instance: true ]})

      _job_instance = UserDocs.JobInstances.create_job_instance(job)

      job =
        Jobs.get_job!(job.id, %{preloads: [ steps: true, processes: true, last_job_instance: true ]})
        |> Jobs.prepare_for_execution()

      job.job_processes |> Enum.at(0) |> Map.get(:process) |> Map.get(:last_process_instance) |> Map.get(:id)
      job.job_processes |> Enum.at(1) |> Map.get(:process) |> Map.get(:last_process_instance) |> Map.get(:id)

      job.job_processes |> Enum.at(0) |> Map.get(:process) |> Map.get(:steps) |> Enum.at(0) |> Map.get(:last_step_instance) |> Map.get(:id)
      job.job_processes |> Enum.at(1) |> Map.get(:process) |> Map.get(:steps) |> Enum.at(0) |> Map.get(:last_step_instance) |> Map.get(:id)

    end

    test "create_job/1 with valid data creates a job instance", %{team: team} do
      attrs = JobsFixtures.job_attrs(:valid, team.id)
      assert {:ok, %Job{} = job} = Jobs.create_job(attrs)
      assert job.name == attrs.name
    end

    test "create_job/1 with invalid data returns error changeset", %{team: team} do
      attrs = JobsFixtures.job_attrs(:invalid, team.id)
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(attrs)
    end

    test "update_job/2 with valid data updates the job instance", %{team: team} do
      job = JobsFixtures.job(team.id)
      attrs = JobsFixtures.job_attrs(:valid, team.id)
      assert {:ok, %Job{} = job} = Jobs.update_job(job, attrs)
      assert job.name == attrs.name
    end

    test "update_job/2 with invalid data returns error changeset", %{team: team} do
      job = JobsFixtures.job(team.id)
      attrs = JobsFixtures.job_attrs(:invalid, team.id)
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the step instance", %{team: team} do
      job = JobsFixtures.job(team.id)
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = JobsFixtures.job()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end

    test "create_job_step/2 adds a step to the job", %{team: team, step: step} do
      job = JobsFixtures.job(team.id)
      {:ok, _job_step} = Jobs.create_job_step(job, step.id)
      job = Jobs.get_job!(job.id, %{preloads: [ steps: true ]})
      assert job.job_steps |> Enum.at(0) |> Map.get(:step) |> Map.get(:id) == step.id
    end

    test "create_job_process/2 adds a process to the job", %{team: team, process: process} do
      job = JobsFixtures.job(team.id)
      {:ok, _job_process} = Jobs.create_job_process(job, process.id)
      job = Jobs.get_job!(job.id, %{preloads: [ processes: true ]})
      assert job.job_processes |> Enum.at(0) |> Map.get(:process) |> Map.get(:id) == process.id
    end

    test "delete_job_step/2 deletes a step from the job", %{team: team, step: step} do
      job = JobsFixtures.job(team.id)
      {:ok, job_step} = Jobs.create_job_step(job, step.id)
      assert {:ok, %JobStep{}} = Jobs.delete_job_step(job_step)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job_step!(job_step.id) end
      job = Jobs.get_job!(job.id, %{preloads: [ steps: true ]})
      assert job.job_steps == []
    end

    test "delete_job_process/2 deletes a process from the job", %{team: team, process: process} do
      job = JobsFixtures.job(team.id)
      {:ok, job_process} = Jobs.create_job_process(job, process.id)
      assert {:ok, %JobProcess{}} = Jobs.delete_job_process(job_process)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job_process!(job_process.id) end
      job = Jobs.get_job!(job.id, %{preloads: [ processes: true ]})
      assert job.job_processes == []
    end

    test "expand_job_process/2 expands the instance", %{team: team, process: process} do
      job = JobsFixtures.job(team.id)
      {:ok, _job_process} = Jobs.create_job_process(job, process.id)
      job = Jobs.get_job!(job.id, %{preloads: %{processes: true}})
      {:ok, job} = Jobs.expand_job_process(job, process.id)
      assert job.job_processes |> Enum.at(0) |> Map.get(:collapsed) == true
    end

    test "update_job_step_instance/2 updates the job", %{team: team, process: process} do
      job = JobsFixtures.job(team.id)
      process = UserDocs.AutomationManager.get_process!(process.id)
      job = Jobs.get_job!(job.id, %{preloads: [ steps: true, processes: true, last_job_instance: true ]})
      _job_instance = UserDocs.JobInstances.create_job_instance(job)
      {:ok, process_instance} =
        UserDocs.ProcessInstances.create_process_instance_from_process(process, Jobs.max_order(job) + 1)

      {:ok, _job_process} = Jobs.create_job_process(job, process.id, process_instance.id)

      job =
        Jobs.get_job!(job.id, %{preloads: [ steps: true, processes: true, last_job_instance: true ]})
        |> Jobs.prepare_for_execution()

      step_instance =
        job.job_processes
        |> Enum.at(0)
        |> Map.get(:process)
        |> Map.get(:steps)
        |> Enum.at(0)
        |> Map.get(:last_step_instance)
        |> Map.put(:status, "complete")

      job = Jobs.update_job_step_instance(job, step_instance)

      assert job.job_processes
        |> Enum.at(0)
        |> Map.get(:process)
        |> Map.get(:steps)
        |> Enum.at(0)
        |> Map.get(:last_step_instance)
        |> Map.get(:status)
        == "complete"
    end
  end
end
