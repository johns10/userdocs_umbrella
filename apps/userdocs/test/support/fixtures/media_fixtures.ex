defmodule UserDocs.MediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Media
  alias UserDocs.Media.Screenshot
  alias UserDocs.Media.File

  alias UserDocs.Automation

  def add_file_to_state(state, opts) do
    opts =
      opts
      |> Keyword.put(:types, [ File ])

    file =  file()

    state
    |> StateHandlers.initialize(opts)
    |> StateHandlers.load([file], File, opts)
  end

  def add_screenshot_to_state(state, opts) do
    opts =
      opts
      |> Keyword.put(:types, [ Screenshot ])

    s = Automation.list_steps(state, opts) |> Enum.at(0)
    f = Media.list_files(state, opts) |> Enum.at(0)
    screenshot = screenshot(s.id)

    state
    |> StateHandlers.initialize(opts)
    |> StateHandlers.load([screenshot], Screenshot, opts)
  end

  def file() do
    {:ok, object } =
      file_attrs(:valid)
      |> Media.create_file()
    object
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
  def file_attrs(:valid) do
    %{
      content_type: ".png",
      filename: UUID.uuid4(),
      hash: UUID.uuid4(),
      size: 100
    }
  end
end
