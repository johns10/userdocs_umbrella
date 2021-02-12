defmodule UserDocsWeb.DocubitLive.Renderers.Ul do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocsWeb.DocubitLive.AddDocubitButton

  def header(_), do: "OL"

  def render(assigns) do
    ~L"""
      <ul>
        <%= render_block(@inner_block, %{}) %>
        <div class="is-justify-self-flex-center is-flex-grow-0">
          <%= AddDocubitButton.render(%{
            text: "+",
            class: "button",
            parent_cid: @parent_cid,
            docubit: @docubit,
            type: "li"}) %>
        </div>
      </ul>
    """
  end
end
