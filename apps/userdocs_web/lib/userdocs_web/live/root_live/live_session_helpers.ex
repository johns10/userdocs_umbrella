defmodule UserDocsWeb.Root.LiveSession do
  @moduledoc false

  def update_session(socket, params) do
    Enum.reduce(params, socket,
      fn({k, v}, inner_socket) ->
        PhoenixLiveSession.put_session(inner_socket, k, v)
      end
    )
  end

  def live_session_updated(socket, params) do
    socket
    |> maybe_update_user_opened_browser(params["user_opened_browser"])
    |> maybe_update_browser_opened(params["browser_opened"])
    |> maybe_update_navigation_drawer_closed(params["navigation_drawer_closed"])
  end

  defp maybe_update_user_opened_browser(socket, nil), do: socket
  defp maybe_update_user_opened_browser(socket, user_opened_browser),
    do: Phoenix.LiveView.assign(socket, :user_opened_browser, user_opened_browser)

  defp maybe_update_browser_opened(socket, nil), do: socket
  defp maybe_update_browser_opened(socket, browser_opened),
    do: Phoenix.LiveView.assign(socket, :browser_opened, browser_opened)

  defp maybe_update_navigation_drawer_closed(socket, nil), do: socket
  defp maybe_update_navigation_drawer_closed(socket, navigation_drawer_closed) do
    Phoenix.LiveView.assign(socket, :navigation_drawer_closed, navigation_drawer_closed)
  end
end
