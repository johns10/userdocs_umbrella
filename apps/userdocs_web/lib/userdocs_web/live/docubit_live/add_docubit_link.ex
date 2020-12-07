defmodule UserDocsWeb.DocubitLive.AddDocubitButton do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <a class=<%= @class %>
        phx-click="create-docubit"
        phx-value-type-id=<%= @type_id %>
        phx-target=<%= @parent_cid %>
        phx-value-docubit-id=<%= @docubit.id %>
      ><%= @text %></a>
    """
  end
end
