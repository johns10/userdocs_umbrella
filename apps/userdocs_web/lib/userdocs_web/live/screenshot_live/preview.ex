defmodule UserDocsWeb.ScreenshotLive.Preview do
  use UserDocsWeb, :live_component

  alias UserDocs.Media
  alias UserDocs.Media.Screenshot

  @impl true
  def update(%{ screenshot: nil } = assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:img_url, "")
      |> assign(:img_alt, "Screenshot not created")
    }
  end
  def update(%{ screenshot: screenshot } = assigns, socket) do
    { img_url, img_alt} =
      case Media.get_screenshot_url(screenshot) do
        { :ok, url } -> { url, screenshot.aws_file.file_name}
        { :not_loaded, path } -> { path, "Screenshot association not loaded, this is probably a new file." }
        { :nofile, path } -> { path, "No file created for this screenshot, go collect your screenshot" }
      end

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:img_url, img_url)
      |> assign(:img_alt, img_alt)
    }
  end
end
