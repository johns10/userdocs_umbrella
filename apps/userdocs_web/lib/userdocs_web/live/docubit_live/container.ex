defmodule UserDocsWeb.DocubitLive.Renderers.Container do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.DocubitLive.AddDocubitButton


  def render(assigns) do
    ~L"""
      <div class="container">
        <%= @inner_content.([]) %>
        <%= AddDocubitButton.render(%{
          text: "+",
          class: "button",
          parent_cid: @parent_cid,
          docubit: @docubit,
          type: "row"}) %>
      </div>
    """
  end
end
