defmodule UserDocsWeb.DocubitLive.Renderers.Ol do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocsWeb.DocubitLive.AddDocubitButton

  def render(assigns) do
    ~L"""
      <ol>
        <%= @inner_content.([]) %>
        <div class="is-justify-self-flex-center is-flex-grow-0">
          <%= AddDocubitButton.render(%{
            text: "+",
            class: "button",
            parent_cid: @parent_cid,
            docubit: @docubit,
            type: "li"}) %>
        </div>
      </ol>
    """
  end
end
