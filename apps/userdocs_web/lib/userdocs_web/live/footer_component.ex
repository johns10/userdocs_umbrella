defmodule UserDocsWeb.FooterComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <%= live_component @socket, @component, @opts %>
    """
  end

  @impl true
  def mount(socket) do
    socket = assign(socket, :action, None)
    {:ok, socket}
  end
end
