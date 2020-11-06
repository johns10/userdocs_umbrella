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


  def file_attrs(:valid) do
    %{
      content_type: ".png",
      filename: UUID.uuid4(),
      hash: UUID.uuid4(),
      size: 100
    }
  end
end
