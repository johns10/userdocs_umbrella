defmodule UserDocsWeb.DocubitLive.Renderers.Ol do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocsWeb.DocubitLive.AddDocubitButton
  alias UserDocsWeb.DocubitLive.Renderers.Base

  def header(_), do: "OL"

  def render(assigns) do
    ~L"""
      <ol>
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
      </ol>
    """
  end
end
