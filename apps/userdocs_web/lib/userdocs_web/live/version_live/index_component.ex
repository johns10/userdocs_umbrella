defmodule UserDocsWeb.VersionLive.IndexComponent do
  use UserDocsWeb, :live_component

  use UserdocsWeb.LiveViewPowHelper

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end
end
