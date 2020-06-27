defmodule UserDocsWeb.PageLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation
  alias UserDocsWeb.ProcessLive.ShowComponent
  alias UserDocsWeb.ProcessLive.FormComponent
  alias UserDocsWeb.Layout

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card" id="<%= @id %>">
      <header class="card-header">
        <p class="card-header-title">
          <%= @object.name %>: <%= @object.url %>
        </p>
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
        <%= live_group(@socket, ShowComponent, FormComponent,
          [
            title: "Processes",
            type: :process,
            parent_type: :page,
            struct: %Automation.Process{},
            objects: @object.processes,
            return_to: Routes.process_index_path(@socket, :index),
            id: "page-"
              <> Integer.to_string(@object.id)
              <> "-processes",
            parent: @object
          ]
        ) %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("expand", _, socket) do
    socket = assign(socket, :expanded, not socket.assigns.expanded)
    {:noreply, socket}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:expanded, false)
      |> assign(:action, :show)

      {:ok, socket}
  end
end
