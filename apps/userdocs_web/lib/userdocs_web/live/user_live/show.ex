defmodule UserDocsWeb.UserLive.Show do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper
  alias UserDocsWeb.Root

  alias UserDocs.Users
  alias UserDocs.Helpers


  def types() do
    [
      UserDocs.Users.User,
      UserDocs.Users.Team,
    ]
  end

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, types())
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: current_user}} = socket) do
    case String.to_integer(id) == current_user.id do
      true ->
        user = Users.get_user!(id, %{team_users: true, teams: true})
        select_lists = %{
          teams: Helpers.select_list(user.teams, :name, true)
        }

        {
          :noreply,
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action))
          |> assign(:user, user)
          |> assign(:select_lists, select_lists)
        }
      false ->
        {
          :noreply,
          socket
        }
    end
  end

  @impl true
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info(%{topic: "user:" <> _user_id, event: "event:configuration_fetched", payload: payload}, socket) do
    IO.puts("#{__MODULE__} received broadcast")
    case socket.assigns.live_action do
      :local_options ->
        send_update(UserDocsWeb.UserLive.LocalFormComponent, %{id: "local-options", params: payload})
        {:noreply, socket}
      _ -> {:noreply, socket}
    end
  end
  def handle_info(%{topic: "user" <> _user_id, event: "event:configuration_saved"}, socket) do
    case socket.assigns.live_action do
      :local_options ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Local Options updated successfully")
          |> push_redirect(to: Routes.user_show_path(socket, :show, socket.assigns.current_user.id))
        }
      _ -> {:noreply, socket}
    end
  end
  def handle_info(%{topic: "user" <> _user_id, event: "event:chrome_found", payload: %{"path" => chrome_path}}, socket) do
    #IO.puts("Handle Info")
    #IO.inspect(chrome_path)
    case socket.assigns.live_action do
      :local_options ->
        send_update(UserDocsWeb.UserLive.LocalFormComponent, %{id: "local-options", chrome_path: chrome_path})
        {:noreply, socket}
      _ -> {:noreply, socket}
    end
  end
  def handle_info(n, s), do: Root.handle_info(n, s)


  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
  defp page_title(:options), do: "User Options"
  defp page_title(:local_options), do: "Local Options"
end
