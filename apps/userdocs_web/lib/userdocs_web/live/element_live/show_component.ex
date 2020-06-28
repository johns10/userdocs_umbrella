defmodule UserDocsWeb.ElementLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout

  @impl true
  def render(assigns) do
    ~L"""
    <strong>Name:</strong>
    <%= @object.name %>
    """
  end
end
