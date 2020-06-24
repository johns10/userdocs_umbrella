defmodule UserDocsWeb.ShowComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <%= @component.render(assigns) %>
    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:expanded, false)
      |> assign(:action, :show)

    {:ok, socket}
  end

  @impl true
  def handle_event("expand", _, socket) do
    socket = assign(socket, :expanded, not socket.assigns.expanded)
    {:noreply, socket}
  end
end
