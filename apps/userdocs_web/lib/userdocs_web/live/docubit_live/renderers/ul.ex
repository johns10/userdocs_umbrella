defmodule UserDocsWeb.DocubitLive.Renderers.Ul do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocsWeb.DocubitLive.AddDocubitButton
  alias UserDocsWeb.DocubitLive.Renderers.Base

  def header(_), do: "UL"

  def render(assigns) do
    ~L"""
      <ul>
        <%= Base.render_inner_content(assigns) %>
        <%= if @editor do %>
          <div class="is-justify-self-flex-center is-flex-grow-0">
            <%= AddDocubitButton.render(%{
              text: "+",
              class: "button",
              parent_cid: @parent_cid,
              docubit: @docubit,
              type: "li"}) %>
          </div>
        <% end %>
      </ul>
    """
  end
end
