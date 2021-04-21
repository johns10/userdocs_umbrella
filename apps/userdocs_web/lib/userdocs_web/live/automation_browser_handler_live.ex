defmodule UserDocsWeb.AutomationBrowserHandlerLive do
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
    attrs = %{ browser_session: nil }
    user = update_user(socket.assigns.current_user, attrs)
    { :noreply, socket |> assign(:current_user, user) }
  end
  def handle_event("open-browser", _params, socket) do
    {
      :noreply,
      socket
      |> assign(:user_opened_browser, true)
      |> push_event("open-browser", %{})
    }
  end
  def handle_event("browser-opened", params, socket) do
    attrs = %{ browser_session: params["sessionId"] }
    user = update_user(socket.assigns.current_user, attrs)
    {
      :noreply,
      socket
      |> assign(:browser_opened, true)
      |> assign(:current_user, user)
    }
  end

  def handle_event("close-browser", _params, socket) do
    attrs = %{ browser_session: nil }
    user = update_user(socket.assigns.current_user, attrs)
    {
      :noreply,
      socket
      |> assign(:user_opened_browser, false)
      |> push_event("close-browser", %{})
      |> assign(:current_user, user)
    }
  end

  def handle_event("browser-closed", _params, socket) do
    attrs = %{ browser_session: nil }
    user = update_user(socket.assigns.current_user, attrs)
    {
      :noreply,
      socket
      |> assign(:browser_opened, false)
      |> assign(:current_user, user)
    }
  end

  def update_user(user, attrs) do
    case UserDocs.Users.update_user_browser_session(user, attrs) do
      { :ok, user } -> user
      { _, changeset }-> raise(changeset)
    end
  end

end
