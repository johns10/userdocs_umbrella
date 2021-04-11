defmodule UserDocsWeb.PageLive do
  use UserdocsWeb.LiveViewPowHelper
  use UserDocsWeb, :live_view

  alias UserDocsWeb.Root

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign(query: "", results: %{})
      |> Root.apply(session, @types)
    }
  end

  @impl true
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)
end
