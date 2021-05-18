defmodule UserDocs.AutomationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Projects
  alias UserDocs.Automation
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.Process
  alias UserDocs.Automation.StepType
  alias UserDocs.WebFixtures

  alias UserDocs.Web

  def state(state, opts) do
    opts =
      opts
      |> Keyword.put(:types, [ Process, StepType, Step ])

    v = Projects.list_versions(state, opts) |> Enum.at(0)
    process = process(v.id)
    step_type = step_type()
    p = Web.list_pages(state, opts) |> Enum.at(0)
    e = Web.list_elements(state, opts) |> Enum.at(0)
    a = Web.list_annotations(state, opts) |> Enum.at(0)
    step = step(p.id, process.id, e.id, a.id, step_type.id)

    state
    |> StateHandlers.initialize(opts)
    |> StateHandlers.load([process], Process, opts)
    |> StateHandlers.load([step], Step, opts)
    |> StateHandlers.load([step_type], StepType, opts)
  end

  def process(version_id) do
    { :ok, process } =
      process_attrs(:valid, version_id)
      |> Automation.create_process()
    process
  end

  def all_valid_step_types() do
    UserDocs.AutomationFixtures.StepTypes.data()
    |> Enum.map(
      fn(st) ->
        { :ok, step_type } = Automation.create_step_type(st)
        step_type
      end
    )
  end

  def step_type() do
    {:ok, step_type } =
      step_type_attrs(:valid)
      |> Automation.create_step_type()
    step_type
  end

  def step(:both) do
    {:ok, step } =
      step_attrs(:valid)
      |> Automation.create_step()

    strategy = WebFixtures.strategy()
    page = WebFixtures.page()
    annotation_type = WebFixtures.annotation_type(:badge)
    element_attrs = WebFixtures.element_attrs(:valid, page.id, strategy.id)
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
  def step(page_id \\ nil, process_id \\ nil,
    element_id \\ nil, annotation_id \\ nil, step_type_id \\ nil) do
    {:ok, step } =
      step_attrs(:valid, page_id, process_id, element_id,
        annotation_id, step_type_id)
      |> Automation.create_step()
      step
  end

  def step_attrs(attr_types, page_id \\ nil, process_id \\ nil, element_id \\ nil, annotation_id \\ nil, step_type_id \\ nil)
  def step_attrs(:valid, page_id, process_id, element_id, annotation_id, step_type_id) do
    %{
      order: Enum.random(1..100),
      page_id: page_id,
      process_id: process_id,
      element_id: element_id,
      annotation_id: annotation_id,
      step_type_id: step_type_id
    }
  end
  def step_attrs(:invalid, page_id, process_id, element_id, annotation_id, step_type_id) do
    %{
      order: nil,
      page_id: page_id,
      process_id: process_id,
      element_id: element_id,
      annotation_id: annotation_id,
      step_type_id: step_type_id
    }
  end

  def step_type_attrs(:valid) do
    %{
      args: [],
      name: UUID.uuid4()
    }
  end
  def step_type_attrs(:invalid) do
    %{ args: nil, name: nil }
  end

  def process_attrs(status, version_id \\ nil)
  def process_attrs(:valid, version_id) do
    %{
      name: UUID.uuid4(),
      order: 1,
      version_id: version_id
    }
  end
  def process_attrs(:invalid, version_id) do
    %{
      name: nil,
      order: 1,
      version_id: version_id
    }
  end

end
