defmodule UserDocs.MediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Media

  def file() do
    {:ok, object } =
      file_attrs(:valid)
      |> Media.create_file()
    object
  end

  def screenshot(file_id, step_id) do
    { :ok, object } =
      screenshot_attrs(:valid, file_id, step_id)
      |> Media.create_screenshot()
    object
  end

  def screenshot_attrs(:valid, file_id, step_id) do
    %{
      name: UUID.uuid4(),
      file_id: file_id,
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
