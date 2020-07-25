defmodule UserDocsWeb.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card" id="<%= @id %>">
      <header class="card-header">
        <%= @header.render(assigns) %>
        <a
          class="navbar-item"
          phx-click="edit"
          phx-target="<%= @myself.cid %>"
          aria-label="more options">
          <span class="icon" >
            <%= if(@action in [:edit, :new]) do %>
              <i class="fa fa-times-circle" aria-hidden="true"></i>
            <%= else %>
              <i class="fa fa-edit" aria-hidden="true"></i>
            <% end %>
          </span>
        </a>
        <a
          class="navbar-item"
          phx-click="expand"
          phx-target="<%= @myself.cid %>"
          aria-label="more options">
          <span class="icon" >
            <i class="fa fa-angle-down" aria-hidden="true"></i>
          </span>
        </a>
      </header>
      <div class="card-content <%= Layout.is_hidden?(assigns) %>">
        <%= live_form @socket, @form,
          type: @type,
          title: @title,
          action: @action,
          struct: @struct,
          select_lists: @select_lists,
          parent: @parent,
          object: @object,
          id: Atom.to_string(@type) <> "-"
            <> Integer.to_string(@object.id)
            <> "-edit-form"
        %>
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
     |> assign(type, object)}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:expanded, false)
      |> assign(:read_only, false)
      |> assign(:action, :edit)

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
end
