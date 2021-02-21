defmodule UserDocsWeb.ModalComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="modal is-active"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div
        class="modal-background"
        phx-click="close"
        phx-target="<%= @myself.cid %>"
      ></div>
      <div class="modal-content">
        <div class="box">
          <div
            class="modal-close is-large"
            phx-click="close"
            phx-target="<%= @myself.cid %>"
          ></div>
          <%= live_component @socket, @component, @opts %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, %{ assigns: %{ opts: opts } } = socket) do
    if opts[:return_to] != nil && opts[:app_name] == "web" do
      { :noreply, push_patch(socket, to: opts[:return_to])}
    else
      send(self(), :close_modal)
      {:noreply, socket}
    end
  end
end
