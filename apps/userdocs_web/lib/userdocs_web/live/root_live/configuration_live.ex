defmodule UserDocsWeb.ConfigurationLive do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="userdocs-configuration" phx-hook="configuration">
      Configuration
      <%= inspect(@configuration) %>
    </div>
    """
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(:configuration, assigns)
    }
  end

  @impl true
  def handle_info({ :add_configuration, data }) do

  end

end
