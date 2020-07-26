defmodule UserDocsWeb.FooterComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card-content <%= @hidden %>" id="<%= @id %>">
      <div class="content <%= Layout.is_hidden?(@expanded, @action) %>">
        <%= live_form @socket, @component, @opts %>
      </div>
    </div>
    <footer class="card-footer <%= @hidden %>">
      <%= if @action not in [:new] do %>
        <a
          phx-click="new"
          phx-target="<%= @myself.cid %>"
          class="card-footer-item"
        >New</a>
      <% else %>
        <a
          phx-click="cancel"
          phx-target="<%= @myself.cid %>"
          class="card-footer-item"
        >Cancel</a>
      <% end %>
    </footer>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:action, :show)
      |> assign(:expanded, :false)
    {:ok, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    IO.puts("New event in footer")
    {:noreply, assign(socket, :action, :new)}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, :action, :show)
    {:noreply, socket}
  end
end
