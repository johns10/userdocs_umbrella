defmodule UserDocsWeb.DocubitLive.Renderers.Li do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocsWeb.DocubitLive.AddDocubitButton

  def render(assigns) do
    ~L"""
      <li>
      test
        <%= @inner_content.([]) %>
      </li>
    """
  end
end
