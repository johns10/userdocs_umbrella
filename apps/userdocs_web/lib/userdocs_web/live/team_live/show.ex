defmodule UserDocsWeb.TeamLive.Show do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users

  alias UserDocsWeb.ComposableBreadCrumb
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root

  def types() do
    [
      UserDocs.Users.Team,
      UserDocs.Documents.Content
    ]
  end

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, types())
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    socket
    |> assign(:modal_action, :show)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    team = Users.get_team!(id, %{ preloads: [ projects: true, users: true, content: true ] })
    default_project = Users.team_default_project(team)

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:team, Map.put(team, :default_project, default_project))
    }
  end

  defp page_title(:show), do: "Show Team"
  defp page_title(:edit), do: "Edit Team"

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)
end
