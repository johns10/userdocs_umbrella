defmodule UserDocs.ProcessInstancesTest do
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

  describe "process_instances" do
    alias UserDocs.ProcessInstances
    alias UserDocs.ProcessInstances.ProcessInstance

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

    test "list_process_instance/0 returns all process instances", %{ process: process } do
      process_instance = JobsFixtures.process_instance(process.id)
      assert ProcessInstances.list_process_instances() == [ process_instance ]
    end

    test "get_process_instance!/1 returns the process_instance with given id", %{ process: process } do
      process_instance = JobsFixtures.process_instance(process.id)
      assert ProcessInstances.get_process_instance!(process_instance.id) == process_instance
    end

    test "create_process_instance/1 with valid data creates a process instance", %{ process: process } do
      attrs = JobsFixtures.process_instance_attrs(:valid, process.id)
      assert {:ok, %ProcessInstance{} = process_instance} = ProcessInstances.create_process_instance(attrs)
      assert process_instance.name == attrs.name
    end

    test "create_process_instance/1 with invalid data returns error changeset", %{ process: process } do
      attrs = JobsFixtures.process_instance_attrs(:invalid, process.id)
      assert {:error, %Ecto.Changeset{}} = ProcessInstances.create_process_instance(attrs)
    end

    test "update_process_instance/2 with valid data updates the process instance", %{ process: process } do
      process_instance = JobsFixtures.process_instance(process.id)
      attrs = JobsFixtures.process_instance_attrs(:valid, process.id)
      assert {:ok, %ProcessInstance{} = process_instance} = ProcessInstances.update_process_instance(process_instance, attrs)
      assert process_instance.name == attrs.name
    end

    test "update_process_instance/2 with invalid data returns error changeset", %{ process: process } do
      process_instance = JobsFixtures.process_instance(process.id)
      attrs = JobsFixtures.process_instance_attrs(:invalid, process.id)
      assert {:error, %Ecto.Changeset{}} = ProcessInstances.update_process_instance(process_instance, attrs)
      assert process_instance == ProcessInstances.get_process_instance!(process_instance.id)
    end

    test "delete_process_instance/1 deletes the step instance", %{ process: process } do
      process_instance = JobsFixtures.process_instance(process.id)
      assert {:ok, %ProcessInstance{}} = ProcessInstances.delete_process_instance(process_instance)
      assert_raise Ecto.NoResultsError, fn -> ProcessInstances.get_process_instance!(process_instance.id) end
    end

    test "change_process_instance/1 returns a process_instance changeset", %{ process: process } do
      process_instance = JobsFixtures.process_instance(process.id)
      assert %Ecto.Changeset{} = ProcessInstances.change_process_instance(process_instance)
    end
  end
end
