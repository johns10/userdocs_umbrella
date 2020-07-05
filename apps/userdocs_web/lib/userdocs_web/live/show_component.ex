defmodule UserDocsWeb.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card" id="<%= @id %>">
      <header class="card-header">
        <p class="card-header-title">
          <%= @name %>
        </p>
        <a
          class="card-header-icon"
          phx-click="edit"
          phx-target="<%= @myself %>"
          aria-label="more options">
          <span class="icon" >
            <%= if(@action == :edit) do %>
              <i class="fa fa-times-circle" aria-hidden="true"></i>
            <%= else %>
              <i class="fa fa-edit" aria-hidden="true"></i>
            <% end %>
          </span>
        </a>
        <a
          class="card-header-icon"
          phx-click="expand"
          phx-target="<%= @myself %>"
          aria-label="more options">
          <span class="icon" >
              <i class="fa fa-angle-down" aria-hidden="true"></i>
          </span>
        </a>
      </header>
      <div class="card-content <%= Layout.is_hidden?(assigns) %>">
        <%= live_component @socket, @form, @opts  %>
        <hr>
        <%= live_component @socket, @show, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    type = Keyword.get(assigns.opts, :type)
    object = Keyword.get(assigns.opts, :object)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(type, object)
     |> assign(:readonly, maybe_readonly(socket.assigns.action))}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:expanded, false)
      |> assign(:read_only, false)
      |> assign(:action, :show)

    {:ok, socket}
  end

  @impl true
  def handle_event("edit", _, %{assigns: %{action: :show}} = socket) do
    socket = assign(socket, :action, :edit)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", _, %{assigns: %{action: :edit}} = socket) do
    socket = assign(socket, :action, :show)
    {:noreply, socket}
  end

  @impl true
  def handle_event("expand", _, socket) do
    socket = assign(socket, :expanded, not socket.assigns.expanded)
    {:noreply, socket}
  end

  def maybe_readonly(:edit), do: false
  def maybe_readonly(_), do: true
end
