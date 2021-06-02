defmodule UserDocsWeb.DrawerLive do
  use UserDocsWeb, :live_component


  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:closed, true)
    }
  end

  @impl true
  def update(assigns, socket) do
    assigns.current_user
    |> UserDocsWeb.SubscriptionTopics.navigation_drawer()
    |> UserDocsWeb.Endpoint.subscribe()

    {
      :ok,
      assign(socket, assigns)
    }
  end

  @impl true
  def handle_event("validate",params, socket) do
    { :noreply, socket }
  end
  def handle_event("toggle-sidebar", _params, socket) do
    send(self(), { :update_session, [ { "navigation_drawer_closed", not socket.assigns.closed } ] })
    { :noreply, socket }
  end

  def checkbox(true) do
    content_tag(:input, id: "collapse-sidebar", class: "toggle", type: "checkbox", checked: true)
  end
  def checkbox(false) do
    content_tag(:input, id: "collapse-sidebar", class: "toggle", type: "checkbox")
  end
  def checkbox(nil) do
    content_tag(:input, id: "collapse-sidebar", class: "toggle", type: "checkbox")
  end
end
