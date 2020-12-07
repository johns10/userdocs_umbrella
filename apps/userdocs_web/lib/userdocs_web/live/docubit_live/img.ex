defmodule UserDocsWeb.DocubitLive.Renderers.Img do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  def render(assigns) do
    ~L"""
      <img>
      <%= @inner_content.([]) %>
    """
  end
end
