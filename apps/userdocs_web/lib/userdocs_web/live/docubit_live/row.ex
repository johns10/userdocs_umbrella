defmodule UserDocsWeb.DocubitLive.Renderers.Row do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.DocubitLive.AddDocubitButton

  def render(assigns) do
    ~L"""
      <div class="is-flex is-flex-direction-row is-justify-content-space-between">
        <%= @inner_content.([]) %>
        <div class="is-justify-self-flex-center is-flex-grow-0">
          <%= AddDocubitButton.render(%{
            text: "+",
            class: "button",
            parent_cid: @parent_cid,
            docubit: @docubit,
            type: "column"}) %>
        </div>
      </div>
    """
  end
end
