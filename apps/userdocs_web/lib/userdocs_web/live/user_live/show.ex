defmodule UserDocsWeb.UserLive.Show do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root

  alias UserDocs.Users
  alias UserDocs.Helpers


  @types [
    UserDocs.Users.User,
    UserDocs.Users.Team,
  ]

  @impl true
  def mount(_params, session, socket) do
    opts = Defaults.opts(socket, @types)
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize(opts)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{ assigns: %{ current_user: current_user }} = socket) do
    case String.to_integer(id) == current_user.id do
      true ->
        user = Users.get_user!(id, %{ team_users: true, teams: true })
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

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
  defp page_title(:options), do: "User Options"
end
