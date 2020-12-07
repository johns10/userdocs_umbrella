defmodule UserDocsWeb.DocubitLive.Renderers.P do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  def render(assigns) do
    ~L"""
      <p>
        <%= IO.inspect(assigns)
        "" %>
        <%= @inner_content.([]) %>
      </p>
    """
  end
end
