defmodule UserDocsWeb.VersionLive.Index do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Projects
  alias UserDocs.Projects.Version
  alias UserDocs.Web
  alias UserDocs.Users
  alias UserDocs.Helpers
  alias UserDocsWeb.ComposableBreadCrumb
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root

  @types [
    UserDocs.Projects.Version
  ]

  @impl true
  def mount(_params, session, socket) do
    opts = Defaults.opts(socket, @types)
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize(opts)
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    socket
    |> assign(:modal_action, :show)
    |> assign(:state_opts, Defaults.opts(socket, @types))
    |> load_versions()
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(_, _, %{ assigns: %{ auth_state: :not_logged_in }} = socket) , do: {:noreply, socket}
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{ "team_id" => team_id, "project_id" => project_id, "id" => id }) do
    socket
    |> assign(:page_title, "Edit Process")
    |> assign(:version, Projects.get_version!(String.to_integer(id), socket, socket.assigns.state_opts))
    |> assign(:select_lists, select_lists(team_id))
    |> assign(:team, Users.get_team!(team_id))
    |> assign(:project, Projects.get_project!(project_id))
    |> prepare_versions()
  end

  defp apply_action(socket, :new, %{ "team_id" => team_id, "project_id" => project_id }) do
    socket
    |> assign(:page_title, "New Version")
    |> assign(:version, %Version{})
    |> assign(:select_lists, select_lists(team_id))
    |> assign(:team, Users.get_team!(team_id))
    |> assign(:project, Projects.get_project!(project_id))
    |> prepare_versions()
  end

  defp apply_action(socket, :index, %{ "team_id" => team_id, "project_id" => project_id }) do
    socket
    |> assign(:page_title, "Listing Versions")
    |> assign(:version, nil)
    |> assign(:team, Users.get_team!(team_id))
    |> assign(:project, Projects.get_project!(project_id))
    |> prepare_versions()
  end

  defp select_lists(team_id) do
    %{
      strategies:
        Web.list_strategies()
        |> Helpers.select_list(:name, false),
      projects:
        Projects.list_projects(%{}, %{ team_id: team_id })
        |> Helpers.select_list(:name, false)
    }
  end

  def prepare_versions(socket) do
    versions = Projects.list_versions(socket, socket.assigns.state_opts)
    socket
    |> assign(:versions, versions)
  end

  def load_versions(socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filters, %{user_id: socket.assigns.current_user.id})

    Projects.load_versions(socket, opts)
  end
end
