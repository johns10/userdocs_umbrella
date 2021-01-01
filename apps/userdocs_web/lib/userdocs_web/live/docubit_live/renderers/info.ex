defmodule UserDocsWeb.DocubitLive.Renderers.Info do
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
    ["Info"]
    |> Base.maybe_content_header(assigns)
  end

  def render(assigns) do
    ~L"""
      <div class="content" style="padding:10px">
        <strong>
          <%= Base.maybe_render_title(@content) %>
        </strong>
        <p>
          <%= @content.body %>
        </p>
      </div>
    """
  end
end
