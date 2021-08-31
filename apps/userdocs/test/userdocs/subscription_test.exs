defmodule UserDocs.SubscriptionTest do
  use UserDocs.DataCase

  describe "automation" do

    alias UserDocs.Subscription
    alias UserDocs.Automation

    def step_attrs(step_id, annotation_id) do
      %{
        id: step_id,
        order: 1,
        name: "test",
        annotation:
        %{
          id: annotation_id,
          name: "test"
        }
      }
    end

    def step_fixture() do
      strategy = UserDocs.WebFixtures.strategy()
      step_type = UserDocs.AutomationFixtures.step_type()
      team = UserDocs.UsersFixtures.team()
      project = UserDocs.ProjectsFixtures.project(team.id)
      version = UserDocs.ProjectsFixtures.version(project.id)
      page = UserDocs.WebFixtures.page(version.id)
      element = UserDocs.WebFixtures.element(page, strategy)
      |> Map.put(:page, page)
      |> Map.put(:strategy, strategy)
      process = UserDocs.AutomationFixtures.process(version.id)
      annotation = UserDocs.WebFixtures.annotation(page)
      step = UserDocs.AutomationFixtures.step(page.id, process.id, element.id, annotation.id, step_type.id)
      step
      |> Map.put(:annotation, annotation)
      |> Map.put(:element, element)
      |> Map.put(:page, page)
      |> Map.put(:step_type, step_type)
      |> Map.put(:screenshot, UserDocs.MediaFixtures.screenshot(step.id))
      |> Map.put(:process, nil)
    end

    test "check_changes" do
      step = step_fixture()
      attrs = step_attrs(step.id, step.annotation.id)
      changeset = Automation.change_step(step, attrs)
      result = Subscription.check_changes(changeset)
    end

    test "traverse_changes" do
      step = step_fixture()
      attrs = step_attrs(step.id, step.annotation.id)
      changeset = Automation.change_step(step, attrs)
      broadcast_actions = Subscription.check_changes(changeset)
      {:ok, updated_step} = Repo.update(changeset)
      result = Subscription.traverse_changes(updated_step, broadcast_actions)
      IO.inspect(result)
      {first_action, first_object} = result |> Enum.at(0)
      assert first_action == :update
      assert first_object.__struct__ == UserDocs.Web.Annotation
    end

    test "broadcast_result" do
      step = step_fixture()
      attrs = step_attrs(step.id, step.annotation.id)
      changeset = Automation.change_step(step, attrs)
      {:ok, updated_step} = Repo.update(changeset)
      Subscription.broadcast_children(updated_step, changeset, [])
    end
  end
end
