defmodule UserDocsWeb.Configuration do
  @moduledoc """
    This module manages sending configuration data to the client
  """
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div phx-hook="configuration">
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    configuration = %{
      image_path: assigns.image_path || "",
      strategy: assigns.strategy || "css",
      user_data_dir_path: assigns.user_data_dir_path || nil,
      css: assigns.css || "",
      overrides: assigns.overrides || %{}
    }
    {
      :ok,
      socket
      |> assign(:configuration, configuration)
      |> push_configurations()
    }
  end

  def push_configurations(socket) do
    socket
    |> push_event("configure", socket.assigns.configuration)
  end

end
