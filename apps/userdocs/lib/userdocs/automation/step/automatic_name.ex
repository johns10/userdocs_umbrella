defmodule UserDocs.Automation.Step.Name do

  require Logger

  import UserDocs.Name

  alias UserDocs.Automation.Step
  alias UserDocs.Automation.StepType
  alias UserDocs.Web.Annotation
  alias UserDocs.Web.Element
  alias UserDocs.Web.Page

  def execute(%Ecto.Changeset{} = step_changeset) do
    step_type =
      case Ecto.Changeset.get_field(step_changeset, :step_type) do
        %StepType{} = step_type -> step_type
        nil -> %StepType{}
      end
    #Logger.debug("Generating an automatic name: #{step_type.name}")
    generate(step_type.name, step_changeset)
  end
  def execute(%{ step_type: %{ name: name }} = step) when is_bitstring(name) do
    generate(name, step)
  end
  def execute(%{ step_type: %Ecto.Association.NotLoaded{}, name: name}) do
    Logger.warn("Step.Name failed because the association wasn't loaded.  Returning current name.")
    name
  end

  def generate("Apply Annotation", %Ecto.Changeset{} = step_changeset) do
    annotation =
      case Ecto.Changeset.get_field(step_changeset, :annotation, "") do
        %Annotation{} = annotation -> annotation
        nil -> %Annotation{}
      end

    order_name(step_changeset)
    <> (annotation.name || "")
  end
  def generate("Apply Annotation" = name, %Step{} = step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> maybe_field(step, [:step_type, :name], " ")
    |> maybe_field(step, [:annotation, :name], "")
  end

  def generate("Navigate", %Ecto.Changeset{} = step_changeset) do
    page = page_or_empty_page(step_changeset)

    order = order_name(step_changeset)
    order
    <> " to "
    <> (page.name || "")
  end
  def generate("Navigate" = name, %Step{} = step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " to ")
    |> maybe_field(step, [:page, :name], "")
  end

  def generate("Set Size Explicit", %Ecto.Changeset{} = step_changeset) do
    width = Ecto.Changeset.get_field(step_changeset, :width, "")
    height = Ecto.Changeset.get_field(step_changeset, :height, "")

    order_name(step_changeset)
    <> Integer.to_string(width) <> "X"
    <> Integer.to_string(height)
  end
  def generate("Set Size Explicit" = name, %Step{} = step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> maybe_field(step, [:step_type, :name], " ")
    |> maybe_field(step, :width, "X")
    |> maybe_field(step, :height, "")
  end

  def generate("Element Screenshot", %Ecto.Changeset{} = step_changeset) do
    element = element_or_empty_element(step_changeset)

    order_name(step_changeset)
    <> (element.name || "")
  end
  def generate("Element Screenshot" = name, %Step{} = step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " ")
    |> maybe_field(step, [:element, :name], "")
  end

  def generate("Clear Annotations", %Ecto.Changeset{} = step_changeset) do
    order_name(step_changeset)
  end
  def generate("Clear Annotations" = name, %Step{} = step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " ")
  end

  def generate("Wait", %Ecto.Changeset{} = step_changeset) do
    element = element_or_empty_element(step_changeset)
    order_name(step_changeset) <> " for "

    <> (element.name || "")
  end
  def generate("Wait" = name, %Step{} = step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " for ")
    |> maybe_field(step, [:element, :name], "")
  end

  def generate("Click", %Ecto.Changeset{} = step_changeset) do
    element = element_or_empty_element(step_changeset)

    order_name(step_changeset) <> " on "
    <> (element.name || "")
  end
  def generate("Click" = name, %Step{} = step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " on ")
    |> maybe_field(step, [:element, :name], "")
  end

  def generate("Fill Field", %Ecto.Changeset{} = step_changeset) do
    element = element_or_empty_element(step_changeset)
    text = Ecto.Changeset.get_field(step_changeset, :text, "")

    element_name = element.name || ""
    guarded_text = Ecto.Changeset.get_field(step_changeset, :text, "") || ""
    order_name(step_changeset)
    <> element_name <> " with "
    <> guarded_text
  end
  def generate("Fill Field" = name, %Step{} = step) do
    Logger.debug("Automatic name generation: #{name}")
    ""
    |> maybe_field(step, :order, ". ")
    |> field(name, " ")
    |> maybe_field(step, [:element, :name], " with ")
    |> maybe_field(step, :text, ". ")
  end

  def generate("Full Screen Screenshot", %Ecto.Changeset{} = step_changeset) do
    order_name(step_changeset)
  end
  def generate("Full Screen Screenshot" = name, %Step{}) do
    Logger.debug("Automatic name generation: #{name}")
    name
  end

  def generate(name, _step) do
    Logger.debug("Unhandled automatic name generation: #{name}") #TODO: Change back to error
    name
  end

  def order_name(changeset) do
    order = Ecto.Changeset.get_field(changeset, :order, "")
    step_type = Ecto.Changeset.get_field(changeset, :step_type, "")
    order_name(order, step_type)
  end
  def order_name(nil, _), do: "0" <> ". "
  def order_name(order, step_type) when is_integer(order) do
    ""
    <> Integer.to_string(order) <> ". "
    <> step_type.name <> " "
  end

  def page_or_empty_page(changeset) do
    case Ecto.Changeset.get_field(changeset, :page, "") do
      %Page{} = page -> page
      nil -> %Page{}
    end
  end

  def element_or_empty_element(changeset) do
    case Ecto.Changeset.get_field(changeset, :element, "") do
      %Element{} = element -> element
      nil -> %Element{}
    end
  end
end
