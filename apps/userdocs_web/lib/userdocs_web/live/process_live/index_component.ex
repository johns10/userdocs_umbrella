defmodule UserDocsWeb.ProcessLive.IndexComponent do
  use UserDocsWeb, :live_component

  use UserdocsWeb.LiveViewPowHelper
  alias UserDocsWeb.ProcessLive.Status
  alias UserDocsWeb.ProcessLive.Runner
  alias UserDocsWeb.ProcessLive.Queuer

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end
end
