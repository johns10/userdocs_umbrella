defmodule UserDocsWeb.ProcessAdministratorLive.ModalComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="phx-modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="phx-modal-content">
        <div
          class="phx-modal-close"
          phx-click="close"
          phx-target="<%= @myself.cid %>"
        >
          <%= raw("&times;") %>
        </div>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    send(self(), {:close_modal})
    {:noreply, socket}
  end
end
