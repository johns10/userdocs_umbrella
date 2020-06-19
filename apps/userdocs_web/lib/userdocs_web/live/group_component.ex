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
                <%= live_show(@socket, UserDocsWeb.ProcessesLive.ShowComponent,
                  "process-" <> Integer.to_string(object.id),
                  object: object,
                  return_to: Routes.processes_index_path(@socket, :index))%>
              <% end %>
            </div>
          </div>
          <footer class="card-footer <%= is_hidden?(assigns) %>">
            <%= if @footer_action in [:new] do %>
              <%= live_footer @socket, UserDocsWeb.ProcessesLive.FormComponent,
                id: "version-" <> Integer.to_string(@opts[:parent].id) <> "-processes-new",
                title: "New Process",
                action: @footer_action,
                process: %UserDocs.Automation.Process{},
                return_to: Routes.automation_index_path(@socket, :index) %>
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
    def handle_event("expand", _, socket) do
      socket = assign(socket, :expanded, not socket.assigns.expanded)
      {:noreply, socket}
    end


    @impl true
    def handle_event("new", _, socket) do
      IO.puts("Got a new event")
      socket = assign(socket, :footer_action, :new)
      {:noreply, socket}
    end

    def is_hidden?(%{expanded: false}), do: " is-hidden"
    def is_hidden?(%{expanded: true}), do: ""
  end
