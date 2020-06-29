defmodule UserDocsWeb.AnnotationLive.ShowComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <strong>Name:</strong>
      <%= @annotation.name %>
    </div>
    """
  end
end
