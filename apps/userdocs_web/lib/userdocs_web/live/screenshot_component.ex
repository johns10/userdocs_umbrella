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
    IO.puts("Creating a screenshot")
    {status, result} = Media.create_aws_file_and_screenshot(payload)
    IO.inspect(result)
    case status do
      :ok ->
        IO.puts("Created File")
    end
    {:noreply, socket}
  end

end
