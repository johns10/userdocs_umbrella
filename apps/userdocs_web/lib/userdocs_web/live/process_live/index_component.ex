defmodule UserDocsWeb.ProcessLive.IndexComponent do
  use UserDocsWeb, :live_component

  use UserdocsWeb.LiveViewPowHelper
  alias UserDocsWeb.ProcessLive.Runner

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end
end
