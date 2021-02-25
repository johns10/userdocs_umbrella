defmodule UserDocs.Media.ScreenshotHelpers do
  require Logger

  alias Mogrify
  alias UserDocs.Media.File
  alias UserDocs.Media
  alias UserDocs.Media.Screenshot
  alias UserDocs.Media.FileHelpers

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

  def handle_screenshots_file({ :ok, screenshot = %{ file: %File{} } }, raw) do
    Logger.debug("The screenshot is there with file #{screenshot.file.id} correctly, probably because the screenshot existed.")

    IO.inspect(@dev_path <> screenshot.file.filename)
    IO.inspect(screenshot)

    { :ok, %{ screenshot: screenshot }}
  end
  def handle_screenshots_file({ :ok, %Screenshot{} = screenshot }, raw) do
    Logger.debug("Handling Screenshot File")
    FileHelpers.encode_hash_save_file(raw, screenshot.file.filename)
    { :ok, screenshot } = UserDocs.Media.update_screenshot(screenshot, %{ aws_file: (@dev_path <> screenshot.file.filename)})
    IO.inspect(screenshot)

    { :ok, screenshot } =
      screenshot
      |> UserDocs.Media.change_screenshot(%{ file_id: file.id})
      |> UserDocs.Media.update_screenshot()

    { :ok, %{ screenshot: screenshot, file: file }}
  end

  # This is some bullshit I put in for the inconsistency after we get done.  Same deal as handle_file_disposition
  def maybe_resize_image(state = { :ok, %{ screenshot: _, file: file } }, "Element Screenshot", element) do
    maybe_resize_image(state, "Element Screenshot", element, file)
  end
  def maybe_resize_image(state = { :ok, %{ screenshot: %{ file: file} } }, "Element Screenshot", element) do
    maybe_resize_image(state, "Element Screenshot", element, file)
  end
  def maybe_resize_image(state, _, _) do
    state
  end
  def maybe_resize_image(state = { :ok, %{ screenshot: _ } }, "Element Screenshot", element, file) do
    IO.puts("Resizing image")
    geometry = "#{element["size"]["width"]}x#{element["size"]["height"]}+#{element["size"]["x"]}+#{element["size"]["y"]}"

    IO.puts(geometry)

    path =
      if Mix.env() in [:dev, :test] do
        @dev_path
      else
        @prod_path
      end

    path <> file.filename
    |> Mogrify.open()
    |> Mogrify.custom("crop", geometry)
    |> Mogrify.save(in_place: true)

    state
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
