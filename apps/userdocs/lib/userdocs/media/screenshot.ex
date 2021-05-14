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
    |> maybe_update_screenshots()
    |> maybe_change_aws_filename()
    |> validate_required([:step_id])
  end

  def maybe_change_aws_filename(%{ data: %{ aws_screenshot: nil }} = changeset), do: changeset
  def maybe_change_aws_filename(%{ data: %{ aws_screenshot: current_aws_path, id: id }} = changeset) when is_integer(id) do
    current_file_name = Screenshots.unpath(current_aws_path)
    { :ok, screenshot } = apply_action(changeset, :update)
    new_file_name = Screenshots.file_name(screenshot, :production)
    if current_file_name != new_file_name do
      new_path = Screenshots.path(new_file_name)
      team = UserDocs.Users.get_screenshot_team!(id)
      { :ok, dest_path } = Screenshots.rename_aws_object(current_aws_path, new_path, team)
      put_change(changeset, :aws_screenshot, dest_path)
    else
      changeset
    end
  end

  def maybe_update_screenshots(changeset) do
    case Ecto.Changeset.get_change(changeset, :base_64) do
      nil -> changeset
      _base_64 -> create_aws_screenshot_or_diff_screenshot(changeset)
    end
  end

  def create_aws_screenshot_or_diff_screenshot(%{ data: %{ id: _ , aws_screenshot: nil }} = changeset) do
    Screenshots.create_aws_screenshot(changeset)
  end
  def create_aws_screenshot_or_diff_screenshot(%{ data: %{ aws_screenshot: _aws_screenshot }} = changeset) do
    Screenshots.update_aws_screenshot(changeset)
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
