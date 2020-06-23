defmodule UserDocsWeb.GroupComponent do
    use UserDocsWeb, :live_component

    @impl true
    def render(assigns) do
      ~L"""
        <div class="card">
          <header class="card-header">
            <p class="card-header-title">
              <%= @opts[:title] %>
            </p>
            <a href="#" class="card-header-icon" aria-label="more options">
              <span class="icon" phx-click="expand" phx-target="<%= @myself %>">
                <i class="fa fa-angle-down" aria-hidden="true"></i>
              </span>
            </a>
          </header>
          <div class="card-content <%= is_hidden?(assigns) %>">
            <div class="content">
              <%= for(object <- @opts[:objects]) do %>
                <%= live_show(@socket, @show,
                  "process-" <> Integer.to_string(object.id),
                  object: object)%>
              <% end %>
            </div>
          </div>
          <footer class="card-footer <%= is_hidden?(assigns) %>">
            <%= if @footer_action in [:new] do %>
              <%= live_footer @socket, @form,
                id: "version-"
                  <> Integer.to_string(@opts[:parent].id)
                  <> "-"
                  <> @opts[:type]
                  <> "form",
                title: "New Process",
                action: @footer_action,
                empty_changeset: @opts[:empty_changeset] %>
            </footer>
          <% else %>
            <a phx-click="new" phx-target="<%= @myself %>" class="card-footer-item">New</a>
          <% end %>
        </div>
      """
    end

    @impl true
    def mount(socket) do
      socket = assign(socket, :expanded, false)
      socket = assign(socket, :footer_action, false)
      {:ok, socket}
    end

    @impl true
    def update(assigns, socket) do
      socket = assign(socket, assigns)
      {:ok, socket}
    end

    @impl true
    def handle_event("expand", _, socket) do
      socket = assign(socket, :expanded, not socket.assigns.expanded)
      {:noreply, socket}
    end


    @impl true
    def handle_event("new", _, socket) do
      IO.puts("New Event")
      socket = assign(socket, :footer_action, :new)
      {:noreply, socket}
    end

    def is_hidden?(%{expanded: false}), do: " is-hidden"
    def is_hidden?(%{expanded: true}), do: ""
  end
