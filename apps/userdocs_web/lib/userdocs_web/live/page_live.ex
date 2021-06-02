defmodule UserDocsWeb.PageLive do
  use UserdocsWeb.LiveViewPowHelper
  use UserDocsWeb, :live_view

  alias UserDocsWeb.Root

  @types []

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

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)
end
