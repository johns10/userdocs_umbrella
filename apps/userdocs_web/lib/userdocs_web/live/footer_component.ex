defmodule UserDocsWeb.FooterComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card-content <%= @hidden %>">
      <div class="content">
        <%=if @action in [:new] do %>
          <%= live_component @socket, @component, @opts ++ [{:action, :new}] %>
        <% end %>
      </div>
    </div>
    <footer class="card-footer <%= @hidden %>">
      <%= if @action not in [:new] do %>
        <a
          phx-click="new"
          phx-target="<%= @myself %>"
          class="card-footer-item"
        >New</a>
      <% else %>
        <a
          phx-click="cancel"
          phx-target="<%= @myself %>"
          class="card-footer-item"
        >Cancel</a>
      <% end %>
    </footer>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    IO.puts("New Event")
    socket = assign(socket, :action, :new)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, :action, :show)
    {:noreply, socket}
  end
end
