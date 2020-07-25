defmodule UserDocsWeb.AnnotationLive.Header do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <p class="card-header-title">
      <%= @name %>
    </p>
    """
  end
end
