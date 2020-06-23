defmodule UserDocsWeb.FooterComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <%= IO.inspect(@component) %>
      <%= live_component @socket, @component, @opts %>
    """
  end

  @impl true
  def mount(socket) do
    IO.puts("Mounting Footer Component")
    socket = assign(socket, :action, None)
    {:ok, socket}
  end
end
