defmodule UserDocsWeb.ProcessLive.Index do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Web
  alias UserDocs.Users
  alias UserDocs.Helpers
  alias UserDocs.Projects
  alias UserDocs.Automation
  alias UserDocs.Automation.Process
  alias UserDocsWeb.ComposableBreadCrumb
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root

  @types [
    UserDocs.Automation.Process
  ]

  @impl true
  def mount(_params, session, socket) do
    opts = Defaults.opts(socket, @types)
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize(opts)
      |> load_processes(opts)
      |> load_versions(opts)
      |> assign(:select_lists, %{})
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = Defaults.opts(socket, @types)

    socket
    |> assign(:modal_action, :show)
    |> assign(:state_opts, opts)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(%{ "team_id" => team_id, "project_id" => project_id, "version_id" => version_id } = params, _url, socket) do
    IO.puts("handling params")
    {
      :noreply,
      do_handle_params(socket, team_id, project_id, version_id)
      |> apply_action(socket.assigns.live_action, params)
    }
  end
  def do_handle_params(socket, team_id, project_id, version_id) do
    socket
    |> assign(:team, Users.get_team!(team_id))
    |> assign(:project, Projects.get_project!(project_id))
    |> assign(:version, Projects.get_version!(version_id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Process")
    |> assign(:process, Automation.get_process!(String.to_integer(id), socket, socket.assigns.state_opts))
    |> assign(:select_lists, select_lists(socket))
    |> prepare_processes()
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Process")
    |> assign(:process, %Process{})
    |> assign(:select_lists, select_lists(socket))
    |> prepare_processes()
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Processes")
    |> assign(:process, nil)
    |> prepare_processes()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    process = Automation.get_process!(id)
    { :ok, _ } = Automation.delete_process(process)
    { :noreply, load_processes(socket, socket.assigns.state_opts) }
  end
  def handle_event("select-version" = n, p, s) do
    { :noreply, socket } = Root.handle_event(n, p, s)
    { :noreply, prepare_processes(socket) }
  end

  def select_lists(socket) do
    %{
      versions:
        Projects.list_versions(socket, socket.assigns.state_opts)
        |> Helpers.select_list(:name, false)
    }
  end

  def prepare_processes(socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filter, {:version_id, socket.assigns.version.id })

    socket
    |> assign(:processes, Automation.list_processes(socket, opts))
  end

  def load_processes(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{user_id: socket.assigns.current_user.id})

    Automation.load_processes(socket, opts)
  end

  def load_versions(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{user_id: socket.assigns.current_user.id})

    Projects.load_versions(socket, opts)
  end
end
