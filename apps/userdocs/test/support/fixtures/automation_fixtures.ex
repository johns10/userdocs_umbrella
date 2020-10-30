defmodule UserDocs.AutomationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Automation

  def step_type() do
    {:ok, step_type } =
      step_type_attrs(:valid)
      |> Automation.create_step_type()
    step_type
  end

  def step() do
    {:ok, team } =
      step_attrs(:valid)
      |> Automation.create_step()
    team
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
