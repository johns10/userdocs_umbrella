defmodule UserDocsWeb.ScreenshotLive.Show do
  use UserDocsWeb, :live_view

  alias UserDocs.Screenshots
  alias UserDocs.Media.Screenshot

  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root

  def types() do
    [
      UserDocs.Media.Screenshot
    ]
  end

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, types())
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = Defaults.state_opts(socket)

    socket
    |> assign(:state_opts, opts)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(%{ "id" => id }, url, socket) do
    screenshot = Screenshots.get_screenshot!(id)
    socket =
      assign_url(socket, screenshot, :aws_screenshot, socket.assigns.current_team)
      |> assign_url(screenshot, :aws_provisional_screenshot, socket.assigns.current_team)
      |> assign_url(screenshot, :aws_diff_screenshot, socket.assigns.current_team)
      |> assign(url: URI.parse(url))

    {
      :noreply,
      socket
      |> assign(:screenshot, screenshot)
    }
  end

  def assign_url(socket, screenshot, key, team) do
    case Screenshots.get_url(Map.get(screenshot, key), team) do
      { :ok, url } -> assign(socket, key, url)
      _ -> socket
    end
  end

  @impl true
  def handle_event("approve-provisional", _, socket) do
    IO.puts("approve Provisional")
    screenshot =
      Screenshots.apply_provisional_screenshot(socket.assigns.screenshot, socket.assigns.current_team)

    { :noreply, assign(socket, :screenshot, screenshot) }
  end
  def handle_event("reject-provisional", _, socket) do
    IO.puts("reject Provisional")
    screenshot =
      Screenshots.reject_provisional_screenshot(socket.assigns.screenshot)
      { :noreply, assign(socket, :screenshot, screenshot) }
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)
end
