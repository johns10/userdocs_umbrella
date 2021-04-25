defmodule UserDocs.MediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Media
  alias UserDocs.Media.Screenshot
  alias UserDocs.Media.File

  alias UserDocs.Automation

  def add_screenshot_to_state(state, opts) do
    opts =
      opts
      |> Keyword.put(:types, [ Screenshot ])

    s = Automation.list_steps(state, opts) |> Enum.at(0)
    screenshot = screenshot(s.id)

    state
    |> StateHandlers.initialize(opts)
    |> StateHandlers.load([screenshot], Screenshot, opts)
  end

  def screenshot(step_id) do
    { :ok, object } =
      screenshot_attrs(:valid, step_id)
      |> Media.create_screenshot()
    object
  end

  def screenshot_attrs(:valid, step_id) do
    %{
      name: UUID.uuid4(),
      step_id: step_id
    }
  end
  def screenshot_attrs(:invalid, step_id) do
    %{
      name: nil,
      step_id: step_id
    }
  end
end
