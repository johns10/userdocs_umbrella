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
      socket
      |> assign(:current_user, assigns.current_user)
      |> assign(:current_team, assigns.current_team)
    }
  end

  @impl true
  def handle_event("validate",params, socket) do
    { :noreply, socket }
  end
  def handle_event("toggle-sidebar", _payload, socket) do
    { :noreply, assign(socket, :closed, not socket.assigns.closed) }
  end

  def checkbox(boolean) do
    if boolean do
      content_tag(:input, id: "collapse-sidebar", class: "toggle", type: "checkbox", checked: true)
    else
      content_tag(:input, id: "collapse-sidebar", class: "toggle", type: "checkbox")
    end
  end
end
