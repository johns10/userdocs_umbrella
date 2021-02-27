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
    { :ok, url } = Media.get_screenshot_url(screenshot)
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:img_url, url)
      |> assign(:img_alt, screenshot.aws_file.file_name)
    }
  end
end
