defmodule UserDocsWeb.DocubitLive.Dragging do
  use UserDocsWeb, :live_component

  def render(assigns) do
    ~L"""
      <div
        id="dragging"
        object-id="<%= @object_id %>"
        object-type="<%= @object_type %>"
      >id: <%= @object_id %></div>
    """
  end
end
