defmodule UserDocs.JobInstancesTest do
  use UserDocs.DataCase

  alias UserDocs.AutomationFixtures
  alias UserDocs.JobsFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.JobsFixtures, as: JobFixtures

  defp fixture(:user), do: UsersFixtures.user()
  defp fixture(:team), do: UsersFixtures.team()
  defp fixture(:strategy), do: WebFixtures.strategy()
  defp fixture(:step_types), do: AutomationFixtures.all_valid_step_types()

  defp fixture(:project, team_id), do: ProjectsFixtures.project(team_id)
  defp fixture(:process, project_id), do: AutomationFixtures.process(project_id)
  defp fixture(:page, project_id), do: WebFixtures.page(project_id)
  defp fixture(:annotation, page_id), do: WebFixtures.annotation(page_id)
  defp fixture(:job, team_id), do: JobFixtures.job(team_id)

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
  defp create_job(%{team: team}), do: %{job: fixture(:job, team.id)}

  describe "job_instances" do
    alias UserDocs.JobInstances
    alias UserDocs.Jobs.JobInstance
    alias UserDocs.Jobs

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
      :create_job
    ]

    test "list_job_instances/0 returns all projects", %{job: job} do
      job_instance = JobFixtures.job_instance(job.id)
      assert JobInstances.list_job_instances() == [ job_instance ]
    end

    test "get_job_instance!/1 returns the job instance with given id", %{job: job} do
      job_instance = JobFixtures.job_instance(job.id)
      assert JobInstances.get_job_instance!(job_instance.id) == job_instance
    end

    test "create_job_instance/1 with valid data creates a job instance", %{job: job} do
      attrs = JobsFixtures.job_instance_attrs(:valid, job.id)
      assert {:ok, %JobInstance{} = job_instance} = JobInstances.create_job_instance(attrs)
      assert job_instance.name == attrs.name
    end

    test "create_job_instance/1 with a job prototypes a job instance", %{step: step, process: process, job: job} do
      {:ok, _job_process} = Jobs.create_job_process(job, process.id)
      {:ok, _job_step} = Jobs.create_job_step(job, step.id)
      {:ok, _job_step} = Jobs.create_job_step(job, step.id)
      job = Jobs.get_job!(job.id, %{preloads: [ processes: true, steps: true ]})
      {:ok, job_instance} = JobInstances.create_job_instance(job)

      job_instance = JobInstances.get_job_instance!(job_instance.id, %{preloads: [ step_instances: true, process_instances: [ step_instances: true ] ]})

      assert job_instance.step_instances |> Enum.at(0) |> Map.get(:step_id) == step.id
      assert job_instance.step_instances |> Enum.at(0) |> Map.get(:job_instance_id) == job_instance.id
      assert job_instance.process_instances |> Enum.at(0) |> Map.get(:process_id) == process.id
      assert job_instance.process_instances |> Enum.at(0) |> Map.get(:job_instance_id) == job_instance.id
      assert job_instance.process_instances |> Enum.at(0) |> Map.get(:step_instances) |> Enum.at(0) |> Map.get(:step_id) == step.id
    end

    test "create_job_instance/1 with invalid data returns error changeset", %{job: job} do
      attrs = JobsFixtures.job_instance_attrs(:invalid, job.id)
      assert {:error, %Ecto.Changeset{}} = JobInstances.create_job_instance(attrs)
    end

    test "update_job_instance/2 with valid data updates the step instance", %{job: job} do
      job_instance = JobsFixtures.job_instance(job.id)
      attrs = JobsFixtures.job_instance_attrs(:valid, job.id)
      assert {:ok, %JobInstance{} = job_instance} = JobInstances.update_job_instance(job_instance, attrs)
      assert job_instance.name == attrs.name
    end

    test "update_job_instance/2 with invalid data returns error changeset", %{job: job} do
      job_instance = JobsFixtures.job_instance(job.id)
      attrs = JobsFixtures.job_instance_attrs(:invalid, job.id)
      assert {:error, %Ecto.Changeset{}} = JobInstances.update_job_instance(job_instance, attrs)
      assert job_instance == JobInstances.get_job_instance!(job_instance.id)
    end

    test "delete_job_instance/1 deletes the step instance", %{job: job} do
      job_instance = JobsFixtures.job_instance(job.id)
      assert {:ok, %JobInstance{}} = JobInstances.delete_job_instance(job_instance)
      assert_raise Ecto.NoResultsError, fn -> JobInstances.get_job_instance!(job_instance.id) end
    end

  end
end
