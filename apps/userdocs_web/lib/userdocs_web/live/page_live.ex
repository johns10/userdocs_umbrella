defmodule UserDocsWeb.PageLive do
  use UserdocsWeb.LiveViewPowHelper
  use UserDocsWeb, :live_view

  alias UserDocsWeb.Root

  @types []

  @impl true
  def mount(_params, session, socket) do
    tokens = %{
      access_token: session["access_token"],
      renewal_token: session["renewal_token"]
    }
    {
      :ok,
      socket
      |> assign(query: "", results: %{})
      |> Root.apply(session, @types)
      |> push_event("tokens", tokens)
    }
  end

  @impl true
  def handle_params(_params, _url, %{assigns: %{auth_state: :not_logged_in}} = socket) do
    {:noreply, socket}
  end
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"logged_in" => "true", "access_token" => access_token, "renewal_token" => renewal_token}) do
    params = %{
      access_token: access_token,
      renewal_token: renewal_token,
      user_id: socket.assigns.current_user.id
    }
    socket
    |> push_event("login-succeeded", params)
  end
  defp apply_action(socket, :index, _), do: socket

  @impl true
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)
end
