defmodule UserDocsWeb.PanelComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <article id="<%= @id %>" class="panel is-primary"
      phx-target="<%= @myself.cid %>"
      phx-page-loading>
      <div class="panel-heading panel-header">
        <div class="level">
          <div class="level-left">
            <%= @title %>
          </div>
          <a
            phx-click="expand"
            phx-target="<%= @myself.cid %>"
            aria-label="Expand">
            <span class="icon">
              <i class="fa fa-angle-down" aria-hidden="true"></i>
            </span>
          </a>
        </div>
      </div>
      <div class="<%= maybe_hidden("panel-block", @expanded) %>">
        <div class="control is-expanded">
          <div class="select is-fullwidth">
            <%= f = form_for :selected, "#",
              phx_change: "select",
              phx_target: @myself.cid %>
              <%= select f, :id, @select_list, value: @default_selected %>
            </form>
          </div>
        </div>
      </div>

      <div class="panel-body">
        <%= for item <- @filtered_items do %>
        <a class="<%= maybe_hidden("panel-block panel-item", @expanded) %>"
            id=<%= item.id %>
            draggable="true"
            phx-hook="editorSource"
            type=<%= @type %>
          >
            <span class="panel-icon">
              <i class="fa fa-copy" aria-hidden="true"></i>
            </span>
            <%= item.name %>
          </a>
        <% end %>
      </div>

    </article>
    """
  end

  @impl true
  def handle_event("expand", _, socket), do: {:noreply, expand(socket)}
  def handle_event("select", %{"selected" => %{"id" => id}}, socket) do
    filtered_items =
      socket.assigns.items_function.(String.to_integer(id), socket.assigns.items)

    socket =
      socket
      |> assign(:filtered_items, filtered_items)

    {:noreply, socket}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:expanded, true)
      |> assign(:selected, nil)
      |> assign(:items, [])

    { :ok, socket }
  end

  @impl true
  def update(assigns, socket) do
    filtered_items = assigns.items_function.(assigns.default_selected, assigns.items)

    socket =
      socket
      |> assign(assigns)
      |> assign(:filtered_items, filtered_items)

    {:ok, socket}
  end

  def maybe_hidden(class, true), do: class <> ""
  def maybe_hidden(class, false), do: class <> " is-hidden"
  def maybe_hidden(_, _), do: IO.inspect("Maybe hidden"); ""

  def expand(socket) do
    socket
    |> assign(:expanded, not socket.assigns.expanded)
  end
end
