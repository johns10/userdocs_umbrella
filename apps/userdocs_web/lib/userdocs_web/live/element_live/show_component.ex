defmodule UserDocsWeb.ElementLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout

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
