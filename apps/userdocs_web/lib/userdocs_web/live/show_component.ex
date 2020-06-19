defmodule UserDocsWeb.ShowComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div>
    <%= live_component @socket, @component, @opts %>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
