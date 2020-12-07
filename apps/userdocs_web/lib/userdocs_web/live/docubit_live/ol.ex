defmodule UserDocsWeb.DocubitLive.Renderers.Ol do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  def render(assigns) do
    ~L"""
      <ol>
        <%= @inner_content.([]) %>
      </ol>
    """
  end
end
