defmodule UserDocs.StepInstancesTest do
  use UserDocs.DataCase

  alias UserDocs.AutomationFixtures
  alias UserDocs.JobsFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures

  defp fixture(:user), do: UsersFixtures.user()
  defp fixture(:team), do: UsersFixtures.team()
  defp fixture(:strategy), do: WebFixtures.strategy()
  defp fixture(:step_types), do: AutomationFixtures.all_valid_step_types()

  defp fixture(:project, team_id), do: ProjectsFixtures.project(team_id)
  defp fixture(:version, project_id), do: ProjectsFixtures.version(project_id)
  defp fixture(:process, version_id), do: AutomationFixtures.process(version_id)
  defp fixture(:page, version_id), do: WebFixtures.page(version_id)
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

  describe "step_instances" do
    alias UserDocs.StepInstances
    alias UserDocs.StepInstances.StepInstance

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

    test "list_step_instance/0 returns all projects", %{ step: step } do
      step_instance = JobsFixtures.step_instance(step.id)
      assert StepInstances.list_step_instances() == [ step_instance ]
    end

    test "get_step_instance!/1 returns the project with given id", %{ step: step } do
      step_instance = JobsFixtures.step_instance(step.id)
      assert StepInstances.get_step_instance!(step_instance.id) == step_instance
    end

    test "get_step_instance_by_uuid!/1 returns a step instance", %{ step: step } do
      step_instance = JobsFixtures.step_instance(step.id)
      assert StepInstances.get_step_instance_by_uuid(step_instance.uuid) == step_instance
    end

    test "get_step_instance!/2 with preload: * returns the step instance with the preloads", %{ step: step, element: element, annotation: annotation } do
      step_instance = JobsFixtures.step_instance(step.id)
      result = StepInstances.get_step_instance!(step_instance.id, %{ preloads: "*"})
      assert result.step.id == step.id
      assert result.step.element.id == element.id
      assert result.step.annotation.id == annotation.id
    end

    #TODO: Potentially move to teams test
    test "list_step_instance_team_users/1 returns the step instance with the breadcrumb to the team preloaded", %{ user: user, team: team, step: step } do
      step_instance = JobsFixtures.step_instance(step.id)
      step_instance_team_users = UserDocs.Authorization.list_step_instance_team_users(step_instance.id)
      assert step_instance_team_users |> Enum.at(0) |> Map.get(:team_id) == team.id
      assert step_instance_team_users |> Enum.at(0) |> Map.get(:user_id) == user.id
    end

    test "create_step_instance/1 with valid data creates a step instance", %{ step: step } do
      attrs = JobsFixtures.step_instance_attrs(:valid, step.id)
      assert {:ok, %StepInstance{} = step_instance} = StepInstances.create_step_instance(attrs)
      assert step_instance.name == attrs.name
    end
"""
    deprecated
    test "create_step_instance_from_job_and_step/2 with valid data creates a step instance with the job set", %{ step: step, team: team } do
      _attrs = JobsFixtures.step_instance_attrs(:valid, step.id)
      job = JobsFixtures.job(team.id)
      assert {:ok, %StepInstance{}} = StepInstances.create_step_instance_from_job_and_step(step, job, 0)
    end
"""
    test "create_step_instance_from_step/2 with valid data creates a step instance with the step preloaded", %{ step: step } do
      {:ok, %StepInstance{}} = StepInstances.create_step_instance_from_step(step, 0)
    end

    test "create_step_instance/1 with invalid data returns error changeset", %{ step: step } do
      attrs = JobsFixtures.step_instance_attrs(:invalid, step.id)
      assert {:error, %Ecto.Changeset{}} = StepInstances.create_step_instance(attrs)
    end

    test "update_step_instance/2 with valid data updates the step instance", %{ step: step } do
      step_instance = JobsFixtures.step_instance(step.id)
      attrs = JobsFixtures.step_instance_attrs(:valid, step.id)
      assert {:ok, %StepInstance{} = step_instance} = StepInstances.update_step_instance(step_instance, attrs)
      assert step_instance.name == attrs.name
    end

    test "update_step_instance/2 with invalid data returns error changeset", %{ step: step } do
      step_instance = JobsFixtures.step_instance(step.id)
      attrs = JobsFixtures.step_instance_attrs(:invalid, step.id)
      assert {:error, %Ecto.Changeset{}} = StepInstances.update_step_instance(step_instance, attrs)
      assert step_instance == StepInstances.get_step_instance!(step_instance.id)
    end

    test "update_step_instance/2 with a screenshot attr updates the screenshot", %{ step: step } do
      _step_instance = JobsFixtures.step_instance(step.id)
      _attrs = JobsFixtures.step_instance_attrs(:valid, step.id)
    end

    test "delete_step_instance/1 deletes the step instance", %{ step: step } do
      step_instance = JobsFixtures.step_instance(step.id)
      assert {:ok, %StepInstance{}} = StepInstances.delete_step_instance(step_instance)
      assert_raise Ecto.NoResultsError, fn -> StepInstances.get_step_instance!(step_instance.id) end
    end

    test "change_step_instance/1 returns a step_instance changeset", %{ step: step } do
      step_instance = JobsFixtures.step_instance(step.id)
      assert %Ecto.Changeset{} = StepInstances.change_step_instance(step_instance)
    end
"""
    Deprecated
    test "format_step_instance_for_export/1 returns a step instance with attrs", %{ step: step, team: team } do
      job = JobsFixtures.job(team.id)
      {:ok, %StepInstance{} = step_instance} = StepInstances.create_step_instance_from_job_and_step(step, job, 0)
      step_instance =
        Map.put(step_instance, :step, step) # TODO: Investigate. Should I have to put the step in the instance?
        |> StepInstances.format_step_instance_for_export()
      assert step_instance.attrs.id == step.id
    end
"""
    test "step_instances_status/1 returns" do
      failed = %StepInstance{ status: "failed" }
      complete = %StepInstance{ status: "complete" }
      started = %StepInstance{ status: "started" }
      not_started = %StepInstance{ status: "not_started" }
      warn = %StepInstance{ status: "warn" }
      assert StepInstances.step_instances_status([ ]) == :none
      assert StepInstances.step_instances_status([ failed ]) == :fail
      assert StepInstances.step_instances_status([ started ]) == :started
      assert StepInstances.step_instances_status([ not_started ]) == :warn
      assert StepInstances.step_instances_status([ warn ]) == :warn
      assert StepInstances.step_instances_status([ complete, failed ]) == :warn
      assert StepInstances.step_instances_status([ complete, warn ]) == :warn
      assert StepInstances.step_instances_status([ complete, not_started ]) == :ok
      assert StepInstances.step_instances_status([ complete, started ]) == :ok
      assert StepInstances.step_instances_status([ complete, complete, failed ]) == :warn
    end
  end
end
