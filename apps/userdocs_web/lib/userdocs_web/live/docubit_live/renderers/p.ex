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
    <%= if @docubit.context.settings.show_h2 do %>
      <h2><%= Base.maybe_render_h2(@content) %></h2>
    <% end %>
    <%= if @docubit.context.settings.show_h2 do %>
      <title><%= Base.maybe_render_title(@content) %></title>
    <% end %>
    <p>
      <%= Base.maybe_render_prefix(@content) %>
      <%= @content.body %>
    </p>
    """
  end
end
