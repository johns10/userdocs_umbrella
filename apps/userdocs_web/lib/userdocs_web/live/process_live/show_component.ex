defmodule UserDocsWeb.ProcessesLive.ShowComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @object.name %></h1>
    """
  end
end
