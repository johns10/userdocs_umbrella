defmodule UserDocs.Media.ScreenshotHelpers do
  require Logger

  alias Mogrify
  alias UserDocs.Automation
  alias UserDocs.Media
  alias UserDocs.Media.Screenshot
  alias UserDocs.Media.FileHelpers
  alias UserDocs.Web.Element

  @dev_path "apps/userdocs_web/assets/static/images/"
  @prod_path "apps/userdocs_web/priv/static/images/"

  def handle_screenshot_upsert_results(state = { :nok, %{ id: nil } }) do
    # Logger.debug("The screenshot upsert failed")
    state
  end
  def handle_screenshot_upsert_results({ :ok, %Screenshot{ id: nil, step_id: step_id } }) do
    # Logger.debug("Screenshot #{step_id} exists, so we retreive it")
    screenshot =
      Media.list_screenshots(%{file: true}, %{step_id: step_id})
      |> Enum.at(0)

    { :ok, screenshot }
  end
  def handle_screenshot_upsert_results(state = { :ok, %{ id: _id, file_id: _file_id, step_id: step_id }}) do
    Logger.debug("Screenshot #{step_id} was created correctly")
    state
  end

  def save_file({ :ok, %Screenshot{} = screenshot }, raw) do
    Logger.debug("Handling Screenshot File")
    step = Automation.get_step!(screenshot.step_id)
    process = Automation.get_process!(step.process_id)
    file_name = process.name <> " " <> Integer.to_string(step.order) <> ".jpeg"
    case FileHelpers.encode_hash_save_file(raw, file_name) do
      %{ filename: filename } -> { :ok, screenshot, filename}
    end
  end

  # This is some bullshit I put in for the inconsistency after we get done.  Same deal as handle_file_disposition
  def maybe_resize_image(state = { :ok, %Screenshot{}, filename }, "Element Screenshot", %{ "size"=> _ } = element) do
    IO.puts("Resizing image")
    geometry = "#{element["size"]["width"]}x#{element["size"]["height"]}+#{element["size"]["x"]}+#{element["size"]["y"]}"

    IO.puts(geometry)

    path =
      if Mix.env() in [:dev, :test] do
        @dev_path
      else
        @prod_path
      end

    path <> filename
    |> Mogrify.open()
    |> Mogrify.custom("crop", geometry)
    |> Mogrify.save(in_place: true)

    state
  end
  def maybe_resize_image(state, stn, e) do
    IO.puts("Not maybe_resize_image")
    IO.inspect(state)
    IO.inspect(stn)
    IO.inspect(e)
    state
  end

  def update_screenshot({ :ok, screenshot, filename }) do
    UserDocs.Media.update_screenshot(screenshot, %{ aws_file: (@dev_path <> filename)})
  end

  def handle_file_disposition({ :ok, result = %{ screenshot: _, file: _ }}) do
    # Logger.debug("Screenshot was created or updated and file was created")
    { :ok, result }
  end
  def handle_file_disposition({ :ok, result = %{ screenshot: _ }}) do
    # Logger.debug("Screenshot was created or updated.  The file wasn't")
    { :ok, result }
  end
end
