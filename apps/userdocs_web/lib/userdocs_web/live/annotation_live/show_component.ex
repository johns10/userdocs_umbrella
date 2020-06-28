defmodule UserDocsWeb.AnnotationLive.ShowComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <strong>Name:</strong>
    <%= @object.name %>
    """
  end
end
