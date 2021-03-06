defmodule UserDocsWeb.SelectorHandler do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div
      id="<%= @id %>"
      phx-hook="selectorTransfer"
    >
    </div>
    """
  end


  @impl true
  def handle_event("transfer_selector", payload, socket) do
    send(self(), {:transfer_selector, payload})
    {:noreply, socket}
  end

end
