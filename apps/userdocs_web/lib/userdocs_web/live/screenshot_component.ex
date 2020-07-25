defmodule UserDocsWeb.ScreenShotHandler do
  use UserDocsWeb, :live_component
  alias UserDocs.Media

  @impl true
  def render(assigns) do
    ~L"""
    <div
      class="card"
      id="<%= @id %>"
      phx-hook="fileTransfer"
    >
    </div>
    """
  end


  @impl true
  def handle_event("create_screenshot", payload, socket) do
    IO.puts("Got a create screenshot event")
    Media.encode_hash_create_file(payload)
    {:noreply, socket}
  end

end
