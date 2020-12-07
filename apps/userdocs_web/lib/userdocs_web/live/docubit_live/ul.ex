defmodule UserDocsWeb.DocubitLive.Renderers.Ul do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  def render(assigns) do
    ~L"""
      <ul>
        <%= @inner_content.([]) %>
      </ul>
    """
  end
end
