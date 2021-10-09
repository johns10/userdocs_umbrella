defmodule UserDocsWeb.ModalComponent do
  @moduledoc """
    A generic modal component, mostly used for displaying forms.
  """
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <input type="checkbox" id="modal" class="modal-toggle" checked>
    <div id="live-modal" class="modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="modal-box">
        <div class="modal-action float-right m-0" phx-click="close" phx-target="<%= @myself.cid %>">
          <svg aria-hidden="true" focusable="false"  class="w-8" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
            <path fill="currentColor" d="M256 8C119 8 8 119 8 256s111 248 248 248 248-111 248-248S393 8 256 8zm0 448c-110.5 0-200-89.5-200-200S145.5 56 256 56s200 89.5 200 200-89.5 200-200 200zm101.8-262.2L295.6 256l62.2 62.2c4.7 4.7 4.7 12.3 0 17l-22.6 22.6c-4.7 4.7-12.3 4.7-17 0L256 295.6l-62.2 62.2c-4.7 4.7-12.3 4.7-17 0l-22.6-22.6c-4.7-4.7-4.7-12.3 0-17l62.2-62.2-62.2-62.2c-4.7-4.7-4.7-12.3 0-17l22.6-22.6c4.7-4.7 12.3-4.7 17 0l62.2 62.2 62.2-62.2c4.7-4.7 12.3-4.7 17 0l22.6 22.6c4.7 4.7 4.7 12.3 0 17z"></path>
          </svg>
        </div>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>

    """
  end

  @impl true
  def handle_event("close", _, socket) do
    opts = socket.assigns.opts
    {:noreply, push_patch(socket, to: opts[:return_to])}
  end
end
