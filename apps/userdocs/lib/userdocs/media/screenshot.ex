defmodule UserDocs.Media.Screenshot do
  use Ecto.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema

  alias UserDocs.Automation.Step

  schema "screenshots" do
    field :name, :string

    belongs_to :step, Step

    field :base_64, :string, virtual: true

    field :aws_file, UserDocs.ScreenshotUploader.Type

    field :aws_screenshot, :string
    field :aws_provisional_screenshot, :string
    field :aws_diff_screenshot, :string

    timestamps()
  end

  @doc false
  def changeset(screenshot, attrs) do
    screenshot
    |> cast(attrs, [:name, :step_id, :base_64, :aws_screenshot, :aws_provisional_screenshot, :aws_diff_screenshot])
    |> foreign_key_constraint(:step_id)
    |> unique_constraint(:step_id)
    |> validate_required([:name])
  end

  def safe(annotation, handlers \\ %{})
  def safe(screenshot = %UserDocs.Media.Screenshot{}, _handlers) do
    base_safe(screenshot)
  end
  def safe(nil, _), do: nil

  def base_safe(screenshot) do
    %{
      id: screenshot.id,
      name: screenshot.name
    }
  end
end
