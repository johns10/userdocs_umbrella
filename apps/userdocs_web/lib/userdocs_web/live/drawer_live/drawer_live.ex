defmodule UserDocsWeb.DrawerLive do
  use UserDocsWeb, :live_view

  alias UserDocs.Jobs.JobInstance
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocsWeb.AutomationManagerLive

  @impl true
  def mount(params, %{"user_id" => user_id} = session, socket) do
    user = Users.get_user!(user_id)
    user = Map.put(user, :selected_team, Users.try_get_team!(user.selected_team_id))
    UserDocsWeb.Endpoint.subscribe("user:" <> to_string(user_id))
    {
      :ok,
      socket
      |> assign(:closed, true)
      |> assign(:current_user, user)
      |> Map.put(:connected?, Phoenix.LiveView.connected?(socket))
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> assign(:browser_opened, Map.get(session, "browser_opened", false))
      |> assign(:user_opened_browser, Map.get(session, "user_opened_browser", false))
      |> assign(:navigation_drawer_closed, Map.get(session, "navigation_drawer_closed", true))
    }
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply, socket}
  end
  def handle_event("toggle-sidebar", _params, socket) do
    send(self(), {:update_session, [{"navigation_drawer_closed", not socket.assigns.navigation_drawer_closed}]})
    {:noreply, socket}
  end

  def checkbox(true),
    do: content_tag(:input, id: "collapse-sidebar", class: "toggle", type: "checkbox", checked: true)
  def checkbox(false),
    do: content_tag(:input, id: "collapse-sidebar", class: "toggle", type: "checkbox")
  def checkbox(nil),
    do: content_tag(:input, id: "collapse-sidebar", class: "toggle", type: "checkbox")

  @impl true
  # Handles Job Instance creation (sends to automation manager)
  def handle_info(%{topic: "user:" <> user_id, event: "create", payload: %JobInstance{} = job_instance}, socket) do
    send_update(AutomationManagerLive, %{id: "automation-manager", event: "new-job-instance"})
    {:noreply, assign(socket, :job_instance, job_instance)}
  end

  # Handles a StepInstance broadcasts (send updates to automation manager, ignore everything else)
  def handle_info(%{topic: "user:" <> _, event: "update", payload: %StepInstance{} = step_instance}, socket) do
    payload = %{id: "automation-manager", event: "update-step-instance", step_instance: step_instance}
    send_update(AutomationManagerLive, payload)
    {:noreply, socket}
  end
  def handle_info(%{topic: "user:" <> _, event: _, payload: %StepInstance{}}, s), do: {:noreply, s}

  # Handles a ProcessInstance broadcasts (send updates to automation manager, ignore everything else)
  def handle_info(%{topic: "user:" <> _, event: "update", payload: %ProcessInstance{} = process_instance}, socket) do
    payload = %{id: "automation-manager", event: "update-process-instance", process_instance: process_instance}
    send_update(AutomationManagerLive, payload)
    {:noreply, socket}
  end

  # Handles user updates (assigns to socket)
  def handle_info(%{topic: "user:" <> user_id, event: "update", payload: %User{} = user}, socket),
    do: {:noreply, assign(socket, :current_user, user)}
  def handle_info({:broadcast, "update", %User{} = user}, socket),
    do: {:noreply, assign(socket, :current_user, user)}


  # Delegates browser events to the user channel handlers, ignores commands
  def handle_info(%{topic: "user:" <> user_id, event: "event:" <> _event_name, payload: _} = info, socket),
    do: {:noreply, UserDocsWeb.UserChannelHandlers.apply(socket, info)}
  def handle_info(%{topic: "user:" <> _, event: _, payload: _}, s), do: {:noreply, s}

  # Delegates live session events
  def handle_info({:update_session, params}, socket),
    do: {:noreply, UserDocsWeb.Root.LiveSession.update_session(socket, params)}
  def handle_info({:live_session_updated, params}, socket),
    do: {:noreply, UserDocsWeb.Root.LiveSession.live_session_updated(socket, params)}
  def types, do: []
end
