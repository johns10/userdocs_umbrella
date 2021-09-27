defmodule UserDocsWeb.API.Schema.Step do
  use Absinthe.Schema.Notation

  alias UserDocsWeb.API.Resolvers

  object :step do
    field :id, :id
    field :order, :integer
    field :name, :string
    field :url, :string
    field :text, :string
    field :width, :integer
    field :height, :integer
    field :page_reference, :string
    field :margin_all, :integer
    field :margin_top, :integer
    field :margin_bottom, :integer
    field :margin_left, :integer
    field :margin_right, :integer

    field :annotation, :annotation, resolve: &Resolvers.Annotation.get_annotation!/3
    field :page, :page, resolve: &Resolvers.Page.get_page!/3
    field :step_type, :step_type, resolve: &Resolvers.StepType.get_step_type!/3
    field :element, :element, resolve: &Resolvers.Element.get_element!/3
    field :screenshot, :screenshot, resolve: &Resolvers.Screenshot.get_screenshot!/3
    field :process, :process, resolve: &Resolvers.Process.get_process!/3
    field :last_step_instance, :step_instance, resolve: &Resolvers.StepInstance.get_step_instance!/3
  end

  input_object :step_input do
    field :id, :id
    field :order, :integer
    field :screenshot, :screenshot_input
    field :last_step_instance, :step_instance_input
  end
end
