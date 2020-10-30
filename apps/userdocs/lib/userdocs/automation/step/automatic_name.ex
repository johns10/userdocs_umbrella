defmodule UserDocs.Automation.Step.Name do

  require Logger

  import UserDocs.Name

  def execute(%{ step_type: %{ name: name }} = step) when is_bitstring(name) do
    generate(name, step)
  end
  def execute(%{ step_type: %Ecto.Association.NotLoaded{}, name: name}) do
    Logger.warn("Step.Name failed because the association wasn't loaded.  Returning current name.")
    name
  end

  def generate("Apply Annotation" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> maybe_field(step, [:step_type, :name], " ")
    |> maybe_field(step, [:annotation, :name], "")
  end
  def generate("Navigate" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " to ")
    |> maybe_field(step, [:page, :name], "")
  end
  def generate("Set Size Explicit" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> maybe_field(step, [:step_type, :name], " ")
    |> maybe_field(step, :width, "X")
    |> maybe_field(step, :height, "")
  end
  def generate("Element Screenshot" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " ")
    |> maybe_field(step, [:element, :name], "")
  end
  def generate("Clear Annotations" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " ")
  end
  def generate("Wait" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " for ")
    |> maybe_field(step, [:element, :name], "")
  end
  def generate("Click" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " on ")
    |> maybe_field(step, [:element, :name], "")
  end
  def generate("Fill Field" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " ")
    |> maybe_field(step, [:element, :name], " with ")
    |> maybe_field(step, :text, ". ")
  end
  def generate("Full Screen Screenshot" = name, step) do
    Logger.debug("Automatic name generation: #{name}")
    name
  end
  def generate(name, _step) do
    Logger.warn("Unhandled automatic name generation: #{name}")
    name
  end
  def generate(_, _) do
    Logger.warn("Generating an automatic name with no current_step")
    ""
  end
end
