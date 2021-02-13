defmodule UserDocsWeb.DocubitLive.Renderers.P do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocsWeb.DocubitLive.Renderers.Base

  def update(%{ docubit: %{} = docubit} = assigns, socket) do
    content = Base.display_content(assigns, docubit)
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:content, content)
    }
  end

  def header(assigns) do
    ["P"]
    |> Base.maybe_content_header(assigns)
  end

  def render(assigns) do
    ~L"""
    <p>
      <%= Base.maybe_render_prefix(@content) %>
      <%= @content.body %>
    </p>
    """
  end
end
