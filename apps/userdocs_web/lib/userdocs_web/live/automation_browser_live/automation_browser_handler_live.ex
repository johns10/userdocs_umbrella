defmodule UserDocsWeb.AutomationBrowserHandlerLive do
  @moduledoc false
  use UserDocsWeb, :live_component

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:user_opened_browser, false)
      |> assign(:browser_opened, false)
    }
  end

  @impl true
  def handle_event("clear-browser", _params, socket) do
    user_id = socket.assigns.current_user.id |> to_string
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:close_browser", %{})
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:clear_browser", %{})
    {:noreply, socket}
  end
  def handle_event("open-browser", _params, socket) do
    user_id = socket.assigns.current_user.id |> to_string
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "event:user_opened_browser", %{})
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:open_browser", %{})
    {:noreply, socket}
  end

  def handle_event("close-browser", _params, socket) do
    user_id = socket.assigns.current_user.id |> to_string
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "event:user_closed_browser", %{})
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:close_browser", %{})
    {:noreply, socket}
  end

  def update_user(user, attrs) do
    case UserDocs.Users.update_user_browser_session(user, attrs) do
      {:ok, user} -> user
      {_, changeset} -> raise(changeset)
    end
  end

end
