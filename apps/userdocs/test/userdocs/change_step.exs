defmodule UserDocs.StepChange do
  use UserDocs.DataCase

  alias UserDocs.Automation
  alias UserDocs.Automation.Step
  alias UserDocs.Web
  alias UserDocs.Web.Element

  alias UserDocs.AutomationFixtures
  alias UserDocs.WebFixtures

  describe "step_changes" do

    def change_fixture() do
      page = WebFixtures.page()
      badge_annotation_type = WebFixtures.annotation_type(:badge)
      outline_annotation_type = WebFixtures.annotation_type(:outline)
      annotation_one =
        WebFixtures.annotation(page)
        |> Map.put(:annotation_type_id, badge_annotation_type.id)
        |> Map.put(:annotation_type, badge_annotation_type)

      annotation_two =
        WebFixtures.annotation(page)
        |> Map.put(:annotation_type_id, outline_annotation_type.id)
        |> Map.put(:annotation_type, outline_annotation_type)

      strategy = WebFixtures.strategy()
      element_one =
        WebFixtures.element(page, strategy)
        |> Map.put(:strategy, strategy)

      element_two =
        WebFixtures.element(page, strategy)
        |> Map.put(:strategy, strategy)

      %{
        empty_step:
          AutomationFixtures.step()
          |> Map.put(:annotation, nil)
          |> Map.put(:element, nil),

        step_with_annotation:
          AutomationFixtures.step()
          |> Map.put(:annotation_id, annotation_one.id)
          |> Map.put(:annotation, annotation_one)
          |> Map.put(:element, nil),

        step_with_element:
          AutomationFixtures.step()
          |> Map.put(:element_id, element_two.id)
          |> Map.put(:element, element_two)
          |> Map.put(:annotation, nil),

        step_with_both:
          AutomationFixtures.step()
          |> Map.put(:element_id, element_two.id)
          |> Map.put(:element, element_two)
          |> Map.put(:annotation_id, annotation_one.id)
          |> Map.put(:annotation, annotation_one),

        annotation_one: annotation_one,
        annotation_two: annotation_two,
        element_one: element_one,
        element_two: element_two,
        strategy: strategy,
        page: page,
        badge_annotation_type: badge_annotation_type,
        outline_annotation_type: outline_annotation_type,
        state: %{
          data: %{
            annotations: [annotation_one, annotation_two],
            elements: [element_one, element_two],
            strategies: [strategy],
            annotation_types: [badge_annotation_type, outline_annotation_type]
          }
        }
      }
    end
    """
    def update_key_and_object(
      state, initial, id_key, object_key, object, excludes
    ) do
      ]changeset, result} =
        initial
        |> Automation.handle_foreign_key_changes(
          %{id_key => object.id}, state)

      assert Map.get(result, id_key) == object.id

      new_object = excludes(Map.get(result, object_key), excludes)
      old_object = excludes(object, excludes)

      assert new_object == old_object

      {changeset, result}
    end

    def excludes(object \\ %{}, excludes \\ [])
    def excludes(object, [:__meta__]) do
      Map.delete(object, :__meta__)
    end
    def excludes(object, []), do: object
    """
    test "changing the element id updates the changes" do
      fx = change_fixture()

      changes = %{element_id: fx.element_one.id}

      # The step got updated, and we loaded the new element
      step =
        fx.step_with_element
        |> Map.put(:element, fx.element_one)

      # The attrs will indicate the old element (two) and params
      element_attrs =
        Map.take(fx.element_two, [:name, :selector, :id])

      # THe step attrs will include the new element id, but the old element
      step_attrs =
        AutomationFixtures.step_attrs(:valid)
        |> Map.put(:element_id, fx.element_one.id)
        |> Map.put(:element, element_attrs)

      changeset = Automation.change_step_with_nested_data(step, step_attrs, fx.state)

    end

    test "update_step updates the data with preloads" do
      fx = change_fixture()
      step = fx.empty_step
      attrs = %{annotation_id: fx.annotation_one.id}
      {:ok, new_step} = Automation.update_step_with_nested_data(step, attrs, fx.state)
      assert new_step.annotation == fx.annotation_one
    end

    test "adding a new element doesn't wipe out the existing annotation" do
      fx = change_fixture()
      step = fx.step_with_annotation
      attrs = %{element_id: nil}
      {:ok, new_step} = Automation.update_step_with_nested_data(step, attrs, fx.state)
      assert new_step.annotation_id == fx.annotation_one.id
      assert step.annotation == fx.annotation_one
    end

    test "creating a step with an element, and changing to a nil element updates the preloads" do
      fx = change_fixture()
      step = fx.step_with_element
      attrs = %{element_id: nil}
      {:ok, new_step} = Automation.update_step_with_nested_data(step, attrs, fx.state)
      # This is how it was, and it might be right
      # assert Map.delete(new_step.element, :__meta__) == Map.delete(%Element{}, :__meta__)
      assert new_step.element == nil
    end

    test "creating an empty step, and adding an element updates the preload" do
      fx = change_fixture()
      step = fx.empty_step
      attrs = %{element_id: fx.element_two.id}
      {:ok, new_step} = Automation.update_step_with_nested_data(step, attrs, fx.state)
      assert new_step.element == fx.element_two
    end

    test "change_nested_foreign_keys returns a changeset that changes the ids, and removes the nested params" do
      fx = change_fixture()
      step = fx.step_with_element
      attrs = %{
        element_id: fx.element_one.id,
        element:
          WebFixtures.element_attrs(:valid)
          |> Map.put(:page_id, fx.page.id)
          |> Map.put(:strategy_id, fx.strategy.id)
          |> Map.put(:id, fx.element_two.id)
      }
      changeset = Step.change_nested_foreign_keys(step, attrs)
      assert changeset.changes.element_id == fx.element_one.id
      assert Map.get(changeset.params, :element, nil) == nil
      Step.change_remaining(step, attrs)
    end

    test "new_step_element changes the step, updates the changeset, and doesn't blow away the annotation" do
      fx = change_fixture()
      step = fx.step_with_element
      annotation_attrs =
        WebFixtures.annotation_attrs(:valid)
          |> Map.put(:page_id, fx.page.id)
      attrs = %{annotation: annotation_attrs}
      changeset = Automation.change_step_with_nested_data(step, attrs, fx.state)
      changeset = Automation.new_step_element(step, changeset)
      assert changeset.changes.annotation.changes.label == annotation_attrs.label
      assert changeset.data.element == nil
      #TODO: Figure out why this doesn't work.
      #assert changeset.changes.element == %Ecto.Changeset{action: :insert, data: %Element{}, valid?: true}
    end

    # Don't think this is valid anymore, we're doing it explicitly now.
    test "creating a step, and changing to a nil element updates the preloads.  Adding attrs and applying creates a new element" do
      fx = change_fixture()
      step = fx.step_with_element
      attrs = %{element_id: nil}
      {:ok, new_step} = Automation.update_step_with_nested_data(step, attrs, fx.state)
      attrs = %{
        element:
          WebFixtures.element_attrs(:valid)
          |> Map.put(:strategy_id, fx.strategy.id)
      }
      {:ok, final_step} = Automation.update_step_with_nested_data(new_step, attrs, fx.state)
      updated_element = Web.get_element!(final_step.element.id)
      assert updated_element.name == attrs.element.name
      assert final_step.element.name == attrs.element.name
    end

  end
end
