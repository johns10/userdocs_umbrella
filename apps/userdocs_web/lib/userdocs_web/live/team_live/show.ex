defmodule UserDocsWeb.TeamLive.Show do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users

  alias UserDocsWeb.ComposableBreadCrumb
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Loaders
  alias UserDocsWeb.Root

  @types [
    UserDocs.Users.Team,
    UserDocs.Documents.Content
  ]

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize(Defaults.base_opts(@types))
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = Defaults.state_opts(socket)

    socket
    |> assign(:modal_action, :show)
    |> assign(:state_opts, opts)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    team = Users.get_team!(id, %{ preloads: [ users: true, default_project: true, content: true ] })
    IO.inspect(team)
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:team, team)
    }
  end

  defp page_title(:show), do: "Show Team"
  defp page_title(:edit), do: "Edit Team"

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)
end
