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
  defp fixture(:team_user, user_id, team_id), do: UsersFixtures.team_user(user_id, team_id)
  defp fixture(:project, team_id), do: ProjectsFixtures.project(team_id)
  defp fixture(:version, project_id), do: ProjectsFixtures.version(project_id)
  defp fixture(:process, version_id), do: AutomationFixtures.process(version_id)
  defp fixture(:page, version_id), do: WebFixtures.page(version_id)
  defp fixture(:strategy), do: WebFixtures.strategy()
  defp fixture(:element, page_id, strategy_id), do: WebFixtures.element(page_id, strategy_id)
  defp fixture(:annotation, page_id), do: WebFixtures.annotation(page_id)
  defp fixture(:step_types), do: AutomationFixtures.all_valid_step_types()
  defp fixture(:step, page_id, process_id, element_id, annotation_id, step_type_id), do: AutomationFixtures.step(page_id, process_id, element_id, annotation_id, step_type_id)
  defp fixture(:screenshot, step_id), do: MediaFixtures.screenshot(step_id)

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
    %{ step_id: fixture(:step, page.id, process.id, element.id, annotation.id, step_types |> Enum.at(0) |> Map.get(:id)) |> Map.get(:id) }
  end
  defp create_screenshot(%{ step_id: step_id }), do: %{ screenshot: fixture(:screenshot, step_id)}
  defp query_step(%{ step_id: step_id }), do: %{ step: UserDocs.Automation.get_step!(step_id) }

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
      :create_step,
      :create_screenshot,
      :query_step
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

    test "add_step_instance_to_job/2 adds a step instance to the queue", %{ team: team, step: step } do
      job = JobsFixtures.job(team.id)
      job = Jobs.get_job!(job.id, %{ preloads: %{ step_instances: true, process_instances: true }})
      { :ok, job } = Jobs.add_step_instance_to_job(job, step.id)
      assert job.step_instances |> Enum.at(0) |> Map.get(:job_id) == job.id
    end

    test "add_process_instance_to_job/2 adds a process instance to the queue", %{ team: team, process: process } do
      job = JobsFixtures.job(team.id)
      job = Jobs.get_job!(job.id, %{ preloads: %{ step_instances: true, process_instances: true }})
      { :ok, job } = Jobs.add_process_instance_to_job(job, process.id)
      assert job.process_instances |> Enum.at(0) |> Map.get(:job_id) == job.id
      assert job.process_instances |> Enum.at(0) |> Map.get(:order) == 1
    end

    test "remove_step_instance_from_job/2 deletes a step instance and removes from queue", %{ team: team, step: step } do
      job = JobsFixtures.job(team.id)
      step_instance = JobsFixtures.step_instance(step.id, job.id)
      job = Jobs.get_job!(job.id, %{ preloads: %{ step_instances: true }})
      { :ok, job } = Jobs.add_step_instance_to_job(job, step_instance)
      { :ok, job } = Jobs.remove_step_instance_from_job(job, step_instance)
      assert job.step_instances == []
      assert_raise Ecto.NoResultsError, fn -> UserDocs.StepInstances.get_step_instance!(step_instance.id) end
    end

    test "remove_process_instance_from_job/2 deletes a process instance and removes from queue", %{ team: team, process: process } do
      job = JobsFixtures.job(team.id)
      process_instance = JobsFixtures.process_instance(process.id, job.id)
      job = Jobs.get_job!(job.id, %{ preloads: %{ process_instances: true }})
      { :ok, job } = Jobs.add_process_instance_to_job(job, process_instance)
      { :ok, job } = Jobs.remove_process_instance_from_job(job, process_instance)
      assert job.process_instances == []
      assert_raise Ecto.NoResultsError, fn -> UserDocs.ProcessInstances.get_process_instance!(process_instance.id) end
    end

    test "expand_process_instance/2 expands the instance", %{ team: team, process: process } do
      job = JobsFixtures.job(team.id)
      process_instance = JobsFixtures.process_instance(process.id, job.id)
      job = Jobs.get_job!(job.id, %{ preloads: %{ process_instances: true }})
      { :ok, job } = Jobs.expand_process_instance(job, process_instance.id)
      assert job.process_instances |> Enum.at(0) |> Map.get(:expanded) == true
    end

    test "clear_job_status/1 sets all process and step instances status to not_started", %{ team: team, step: step, process: process } do
      job = JobsFixtures.job(team.id)
      { :ok, process_instance } =
        JobsFixtures.process_instance(process.id, job.id)
        |> UserDocs.ProcessInstances.update_process_instance(%{ status: "complete"})

      { :ok, step_instance } =
        JobsFixtures.step_instance(step.id, nil, process_instance.id)
        |> UserDocs.StepInstances.update_step_instance(%{ status: "complete"})

      { :ok, step_instance_two } =
        JobsFixtures.step_instance(step.id, job.id)
        |> UserDocs.StepInstances.update_step_instance(%{ status: "complete"})

      preloaded_process_instance = Map.put(process_instance, :step_instances, [ step_instance ])

      job =
        Jobs.get_job!(job.id, %{ preloads: %{ step_instances: true }})
        |> Map.put(:process_instances, [ preloaded_process_instance ])

      { :ok, job } = Jobs.reset_job_status(job)

      assert job.process_instances |> Enum.at(0) |> Map.get(:status) == "not_started"
      assert job.process_instances |> Enum.at(0) |> Map.get(:step_instances) |> Enum.at(0) |> Map.get(:status) == "not_started"
      assert job.step_instances |> Enum.at(0) |> Map.get(:status) == "not_started"
    end

    test "export_job/1 exports stuff in the right order", %{ team: team, step: step, process: process } do
      job = JobsFixtures.job(team.id)
      pi1 = JobsFixtures.process_instance(process.id, job.id) |> Map.put(:process, process) |> Map.put(:order, 1)
      si1 = JobsFixtures.step_instance(step.id, nil, pi1.id) |> Map.put(:step, step)
      si2 = JobsFixtures.step_instance(step.id, nil, pi1.id) |> Map.put(:step, step)
      pi2 = JobsFixtures.process_instance(process.id, job.id) |> Map.put(:process, process) |> Map.put(:order, 2)
      si3 = JobsFixtures.step_instance(step.id, nil, pi2.id) |> Map.put(:step, step)
      si4 = JobsFixtures.step_instance(step.id, nil, pi2.id) |> Map.put(:step, step)
      pi1 = Map.put(pi1, :step_instances, [ si1, si2 ])
      pi2 = Map.put(pi2, :step_instances, [ si3, si4 ])
      job =
        Jobs.get_job!(job.id, %{ preloads: %{ step_instances: true }})
        |> Map.put(:process_instances, [ pi1, pi2 ])
        |> Map.put(:step_instances, [])

      queue = Jobs.export_job(job)
      assert queue |> Enum.at(1) |> Map.get(:process_instance_id) == pi1.id
    end
  end
end
