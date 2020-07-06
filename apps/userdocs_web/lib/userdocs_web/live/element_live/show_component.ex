defmodule UserDocsWeb.ElementLive.ShowComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <strong>Name:</strong>
      <%= @element.name %>
    </div>
    """
  end
end
