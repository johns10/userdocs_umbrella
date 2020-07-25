defmodule UserDocsWeb.PageLive.Header do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <p class="card-header-title" style="margin-bottom:0px;">
      <%= @name %>
    </p>
    """
  end
end
