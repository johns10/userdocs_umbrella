defmodule UserDocs.AutomationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Automation
  alias UserDocs.WebFixtures

  def step_type() do
    {:ok, step_type } =
      step_type_attrs(:valid)
      |> Automation.create_step_type()
    step_type
  end

  def step() do
    {:ok, step } =
      step_attrs(:valid)
      |> Automation.create_step()
      step
  end
  def step(:both) do
    {:ok, step } =
      step_attrs(:valid)
      |> Automation.create_step()

    strategy = WebFixtures.strategy()
    page = WebFixtures.page()
    annotation_type = WebFixtures.annotation_type(:badge)

    element_attrs =
      WebFixtures.element_attrs(:valid)
      |> Map.put(:strategy_id, strategy.id)
      |> Map.put(:page_id, page.id)

    annotation_attrs =
      WebFixtures.annotation_attrs(:valid)
      |> Map.put(:annotation_type_id, annotation_type.id)
      |> Map.put(:page_id, page.id)

    attrs = %{
      element: element_attrs,
      annotation: annotation_attrs
    }

    { :ok, step } =
      step
      |> Map.put(:element, nil)
      |> Map.put(:annotation, nil)
      |> Automation.update_step(attrs)

    step
  end

  def step_attrs(:valid) do
    %{
      order: 42
    }
  end

  def step_type_attrs(:valid) do
    %{ args: [], name: "some name" }
  end

end
