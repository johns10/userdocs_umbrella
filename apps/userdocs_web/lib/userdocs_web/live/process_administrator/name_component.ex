defmodule UserDocsWeb.ProcessAdministratorLive.NameComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.ProcessAdministratorLive.ID

  @impl true
  def render(assigns) do
    ~L"""
      <div id="<%= @object.name %>">
        <%= @object.name %>
      </div>
    """
  end

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end
end
