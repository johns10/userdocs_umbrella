defmodule UserDocsWeb.ScreenShotHandler do
  use UserDocsWeb, :live_component
  alias UserDocs.Media
  alias UserDocs.Screenshots

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div
      id="<%= @id %>"
      phx-hook="fileTransfer"
    >
    </div>
    """
  end


  @impl true
  def handle_event("create_screenshot",
    %{ "attrs" => %{ "screenshot" => %{ "id" => screenshot_id } = screenshot_attrs }}, socket
  ) do
    screenshot = Screenshots.get_screenshot!(screenshot_id)
    { :ok, screenshot } = Screenshots.update_screenshot(screenshot, screenshot_attrs, socket.assigns.team)
    send(self(), { :broadcast, "update", screenshot })
    {:noreply, socket}
  end

end
