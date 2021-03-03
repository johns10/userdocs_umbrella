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
    |> assign(:select_lists, %{})
    |> assign(:state_opts, Defaults.opts(socket, @types))
    |> load_versions()
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(%{ "project_id" => project_id } = params, url, socket) do
    project = Projects.get_project!(project_id)
    team = Users.get_team!(project.team_id)
    socket =
      socket
      |> assign(:current_project, project)
      |> assign(:current_team, team)

    do_handle_params(params, url, socket, String.to_integer(project_id))
  end
  def handle_params(params, url, socket) do
    do_handle_params(params, url, socket, socket.assigns.current_project.id)
  end
  def do_handle_params(params, _url, socket, project_id) do
    {
      :noreply,
      socket
      |> assign(:select_lists, select_lists(socket.assigns.current_team.id))
      |> prepare_versions(project_id)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  @impl true
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)


  @impl true
  def handle_info(%{topic: _, event: _, payload: %UserDocs.Users.User{} = user} = sub_data, socket) do
    {
      :noreply,
      socket
      |> prepare_versions(user.selected_project_id)
      |> push_patch(to: Routes.version_index_path(socket, :index))
    }
  end
  def handle_info(d, s), do: Root.handle_info(d, s)

  defp apply_action(socket, :edit, %{ "id" => id }) do
    socket
    |> assign(:page_title, "Edit Process")
    |> assign(:version, Projects.get_version!(String.to_integer(id), socket, socket.assigns.state_opts))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Version")
    |> assign(:version, %Version{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Versions")
    |> assign(:version, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Versions")
    |> assign(:version, nil)
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

  def prepare_versions(socket, project_id) do
    opts = Keyword.put(socket.assigns.state_opts, :filter, { :project_id, project_id })
    versions = Projects.list_versions(socket, opts)
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
