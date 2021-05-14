defmodule UserDocsWeb.API.Schema.Screenshot do
  use Absinthe.Schema.Notation

  object :screenshot do
    field :id, :id
    field :step_id, :id
    field :name, :string
    field :aws_screenshot, :string
    field :aws_provisional_screenshot, :string
    field :aws_diff_screenshot, :string
    field :base64, :string do
      resolve fn parent, _, _ -> {:ok, parent.base_64} end
    end
  end

  input_object :screenshot_input do
    field :id, :id
    field :name, :string
    field :step_id, :id
    field :base64, :string do
      resolve fn parent, _, _ -> {:ok, parent.base_64} end
    end
  end
end
