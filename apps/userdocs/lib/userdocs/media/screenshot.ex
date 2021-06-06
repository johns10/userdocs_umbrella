defmodule UserDocs.Media.Screenshot do
  use Ecto.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema

  alias UserDocs.Automation.Step
  alias UserDocs.Screenshots
  alias UserDocs.Media.Screenshot

  schema "screenshots" do
    field :name, :string

    belongs_to :step, Step

    field :base64, :string, virtual: true

    field :aws_file, UserDocs.ScreenshotUploader.Type

    field :aws_screenshot, :string
    field :aws_provisional_screenshot, :string
    field :aws_diff_screenshot, :string

    timestamps()
  end

  @doc false
  def changeset(screenshot, attrs) do
    screenshot
    |> cast(attrs, [:name, :step_id, :base64, :aws_screenshot, :aws_provisional_screenshot, :aws_diff_screenshot])
    |> foreign_key_constraint(:step_id)
    |> unique_constraint(:step_id)
    |> maybe_update_screenshots()
    |> validate_required([:step_id])
  end

  def maybe_update_screenshots(changeset) do
    case Ecto.Changeset.get_change(changeset, :base64) do
      nil -> changeset
      _base64 -> create_aws_screenshot_or_diff_screenshot(changeset)
    end
  end

  def create_aws_screenshot_or_diff_screenshot(%{ data: %{ id: _ , aws_screenshot: nil }} = changeset) do
    Screenshots.create_aws_screenshot(changeset)
  end
  def create_aws_screenshot_or_diff_screenshot(%{ data: %{ aws_screenshot: _aws_screenshot }} = changeset) do
    Screenshots.update_aws_screenshot(changeset)
  end

  def safe(annotation, handlers \\ %{})
  def safe(screenshot = %Screenshot{}, _handlers) do
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
