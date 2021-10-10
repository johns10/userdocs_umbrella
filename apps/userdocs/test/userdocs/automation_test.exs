defmodule UserDocs.AutomationTest do
  use UserDocs.DataCase

  alias UserDocs.AutomationFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.MediaFixtures

  defp fixture(:user), do: UsersFixtures.user()
  defp fixture(:team), do: UsersFixtures.team()
  defp fixture(:step_types), do: AutomationFixtures.all_valid_step_types()
  defp fixture(:strategy), do: WebFixtures.strategy()

  defp fixture(:project, team_id, strategy_id), do: ProjectsFixtures.project(team_id, strategy_id)
  defp fixture(:process, project_id), do: AutomationFixtures.process(project_id)
  defp fixture(:page, project_id), do: WebFixtures.page(project_id)
  defp fixture(:annotation, page_id), do: WebFixtures.annotation(page_id)
  defp fixture(:screenshot, step_id), do: MediaFixtures.screenshot(step_id)

  defp fixture(:element, page_id, strategy_id), do: WebFixtures.element(page_id, strategy_id)
  defp fixture(:team_user, user_id, team_id), do: UsersFixtures.team_user(user_id, team_id)

  defp create_user(_), do: %{user: fixture(:user)}
  defp create_team(_), do: %{team: fixture(:team)}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: fixture(:team_user, user.id, team.id)}
  defp create_project(%{team: team, strategy: strategy}), do: %{project: fixture(:project, team.id, strategy.id)}
  defp create_process(%{project: project}), do: %{process: fixture(:process, project.id)}
  defp create_page(%{project: project}), do: %{page: fixture(:page, project.id)}
  defp create_strategy(_), do: %{strategy: fixture(:strategy)}
  defp create_element(%{page: page, strategy: strategy}), do: %{element: fixture(:element, page.id, strategy.id)}
  defp create_annotation(%{page: page}), do: %{annotation: fixture(:annotation, page.id)}
  defp create_step_types(_), do: %{step_types: fixture(:step_types)}

  alias UserDocs.Automation

  describe "step_types" do
    alias UserDocs.Automation.StepType

    test "list_step_types/0 returns all step_types" do
      step_type = AutomationFixtures.step_type()
      assert Automation.list_step_types() == [step_type]
    end

    test "get_step_type!/1 returns the step_type with given id" do
      step_type = AutomationFixtures.step_type()
      assert Automation.get_step_type!(step_type.id) == step_type
    end

    test "create_step_type/1 with valid data creates a step_type" do
      attrs = AutomationFixtures.step_type_attrs(:valid)
      assert {:ok, %StepType{} = step_type} = Automation.create_step_type(attrs)
      assert step_type.args == []
      assert step_type.name == attrs.name
    end

    test "create_step_type/1 with invalid data returns error changeset" do
      attrs = AutomationFixtures.step_type_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Automation.create_step_type(attrs)
    end

    test "update_step_type/2 with valid data updates the step_type" do
      step_type = AutomationFixtures.step_type()
      attrs = AutomationFixtures.step_type_attrs(:valid)
      assert {:ok, %StepType{} = step_type} = Automation.update_step_type(step_type, attrs)
      assert step_type.args == []
      assert step_type.name == attrs.name
    end

    test "update_step_type/2 with invalid data returns error changeset" do
      step_type = AutomationFixtures.step_type()
      attrs = AutomationFixtures.step_type_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Automation.update_step_type(step_type, attrs)
      assert step_type == Automation.get_step_type!(step_type.id)
    end

    test "delete_step_type/1 deletes the step_type" do
      step_type = AutomationFixtures.step_type()
      assert {:ok, %StepType{}} = Automation.delete_step_type(step_type)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_step_type!(step_type.id) end
    end

    test "change_step_type/1 returns a step_type changeset" do
      step_type = AutomationFixtures.step_type()
      assert %Ecto.Changeset{} = Automation.change_step_type(step_type)
    end
  end

  describe "steps" do
    alias UserDocs.Automation.Step
    alias UserDocs.AutomationFixtures

    setup [
      :create_user,
      :create_strategy,
      :create_team,
      :create_team_user,
      :create_project,
      :create_process,
      :create_page,
      :create_element,
      :create_annotation,
      :create_step_types
    ]

    def validate_step_fields(step_one, step_two) do
      assert step_one.order == step_two.order
      assert step_one.name == step_two.name
      assert step_one.url == step_two.url
    end

    test "list_steps/0 returns all steps" do
      step = AutomationFixtures.step()
      assert Automation.list_steps() == [step]
    end

    test "get_step!/1 returns the step with given id" do
      step = AutomationFixtures.step()
      fetched_step = Automation.get_step!(step.id)
      validate_step_fields(step, fetched_step)
    end

    test "create_step/1 with valid data creates a step" do
      attrs = AutomationFixtures.step_attrs(:valid)
      assert {:ok, %Step{} = step} = Automation.create_step(attrs)
      assert step.order == attrs.order
    end

    test "create_step/1 with invalid data returns error changeset" do
      attrs = AutomationFixtures.step_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Automation.create_step(attrs)
    end

    test "update_step/2 with valid data updates the step" do
      step = AutomationFixtures.step()
      attrs = AutomationFixtures.step_attrs(:valid)
      assert {:ok, %Step{} = updated_step} = Automation.update_step(step, attrs)
      assert updated_step.order == attrs.order
    end

    test "runner_update_step/2 with valid data updates the step" do
      step = AutomationFixtures.step()
      step_instance_attrs = %{status: "not_started", step_id: step.id}
      {:ok, step_instance} = UserDocs.StepInstances.create_step_instance(step_instance_attrs)
      step = Map.put(step, :last_step_instance, step_instance)
      step_attrs = %{last_step_instance: %{id: step_instance.id, status: "complete"}}
      {:ok, step} = Automation.runner_update_step(step, step_attrs)
      assert step.last_step_instance.status == "complete"
    end

    test "update_step/2 with invalid data returns error changeset" do
      step = AutomationFixtures.step()
      attrs = AutomationFixtures.step_attrs(:invalid)
      assert {:error, %Ecto.Changeset{}} = Automation.update_step(step, attrs)
      fetched_step = Automation.get_step!(step.id)
      validate_step_fields(step, fetched_step)
    end

    test "delete_step/1 deletes the step" do
      step = AutomationFixtures.step()
      assert {:ok, %Step{}} = Automation.delete_step(step)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_step!(step.id) end
    end

    test "change_step/1 returns a step changeset" do
      step = AutomationFixtures.step()
      assert %Ecto.Changeset{} = Automation.change_step(step)
    end

  end

  describe "processes" do
    alias UserDocs.Automation.Process

    setup [
      :create_user,
      :create_strategy,
      :create_team,
      :create_team_user,
      :create_project
    ]

    test "list_processes/0 returns all processes", %{project: project} do
      process = AutomationFixtures.process(project.id)
      assert Automation.list_processes() == [process]
    end

    test "get_process!/1 returns the process with given id", %{project: project} do
      process = AutomationFixtures.process(project.id)
      assert Automation.get_process!(process.id) == process
    end

    test "create_process/1 with valid data creates a process", %{project: project} do
      attrs = AutomationFixtures.process_attrs(:valid, project.id)
      assert {:ok, %Process{} = process} = Automation.create_process(attrs)
      assert process.name == attrs.name
    end

    test "create_process/1 with invalid data returns error changeset", %{project: project} do
      attrs = AutomationFixtures.process_attrs(:invalid, project.id)
      assert {:error, %Ecto.Changeset{}} = Automation.create_process(attrs)
    end

    test "update_process/2 with valid data updates the process", %{project: project} do
      process = AutomationFixtures.process(project.id)
      attrs = AutomationFixtures.process_attrs(:valid, project.id)
      assert {:ok, %Process{} = process} = Automation.update_process(process, attrs)
      assert process.name == attrs.name
    end

    test "update_process/2 with invalid data returns error changeset", %{project: project} do
      process = AutomationFixtures.process(project.id)
      attrs = AutomationFixtures.process_attrs(:invalid, project.id)
      assert {:error, %Ecto.Changeset{}} = Automation.update_process(process, attrs)
      assert process == Automation.get_process!(process.id)
    end

    test "delete_process/1 deletes the process", %{project: project} do
      process = AutomationFixtures.process(project.id)
      assert {:ok, %Process{}} = Automation.delete_process(process)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_process!(process.id) end
    end

    test "change_process/1 returns a process changeset", %{project: project} do
      process = AutomationFixtures.process(project.id)
      assert %Ecto.Changeset{} = Automation.change_process(process)
    end
  end

end
