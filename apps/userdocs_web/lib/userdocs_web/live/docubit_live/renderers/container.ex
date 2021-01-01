defmodule UserDocsWeb.DocubitLive.Renderers.Container do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.DocubitLive.AddDocubitButton
  alias UserDocsWeb.DocubitLive.Renderers.Base

  def header(_), do: "Container"

  def render(assigns) do
    ~L"""
      <div class="container">
        <%= Base.render_inner_content(assigns) %>
        <%= if @editor do %>
          <%= AddDocubitButton.render(%{
            text: "+",
            class: "button",
            parent_cid: @parent_cid,
            docubit: @docubit,
            type: "row"}) %>
        <% end %>
      </div>
    """
  end
end
