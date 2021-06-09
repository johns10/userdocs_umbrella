defmodule UserDocsWeb.ScreenshotLive.Preview do
  use UserDocsWeb, :live_component

  alias UserDocs.Screenshots
  alias UserDocs.Media.Screenshot

  @impl true
  def update(%{ screenshot: nil } = assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:status, nil)
      |> assign(:img_url, "")
      |> assign(:img_alt, "Screenshot not created")
    }
  end
  def update(%{ screenshot: screenshot } = assigns, socket) do
    { img_url, img_alt} =
      case Screenshots.get_screenshot_url(screenshot, assigns.team) do
        { :ok, url } -> { url, screenshot.aws_screenshot }
        { :not_loaded, path } -> { path, "Screenshot association not loaded, this is probably a new file." }
        { :nofile, path } -> { path, "No file created for screenshot #{screenshot.id}, go collect your screenshot" }
      end

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:img_url, img_url)
      |> assign(:img_alt, img_alt)
      |> assign(:status, status(screenshot))
    }
  end

  def status(%Screenshot{ aws_screenshot: _, aws_provisional_screenshot: nil, aws_diff_screenshot: nil }), do: :ok
  def status(%Screenshot{ aws_screenshot: _, aws_provisional_screenshot: _, aws_diff_screenshot: nil }), do: :warn
  def status(%Screenshot{ aws_screenshot: _, aws_provisional_screenshot: _, aws_diff_screenshot: _ }), do: :warn
  def status(%Screenshot{}), do: nil
end
