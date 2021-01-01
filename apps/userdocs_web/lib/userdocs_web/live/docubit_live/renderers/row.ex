defmodule UserDocsWeb.DocubitLive.Renderers.Row do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.DocubitLive.AddDocubitButton
  alias UserDocsWeb.DocubitLive.Renderers.Base

  def header(_), do: "Row"

  def render(assigns) do
    ~L"""
      <div class="is-flex is-flex-direction-row is-justify-content-space-between">
        <%= Base.render_inner_content(assigns) %>
        <%= if @editor do %>
          <div class="is-justify-self-flex-center is-flex-grow-0">
            <%= AddDocubitButton.render(%{
              text: "+",
              class: "button",
              parent_cid: @parent_cid,
              docubit: @docubit,
              type: "column"}) %>
          </div>
        <% end %>
      </div>
    """
  end
end
