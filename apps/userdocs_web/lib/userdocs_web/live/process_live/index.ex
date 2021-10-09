defmodule UserDocsWeb.ProcessLive.Index do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocs.Helpers
  alias UserDocs.Projects
  alias UserDocs.Automation
  alias UserDocs.Automation.Process
  alias UserDocs.Media.Screenshot
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root
  alias UserDocsWeb.ProcessLive.Status
  alias UserDocsWeb.ProcessLive.Runner
  alias UserDocsWeb.ProcessLive.Queuer

  def types(), do: [Process, ProcessInstance, Screenshot]

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, types())
      |> assign(:select_lists, %{})
      |> initialize()
    }
  end

  def initialize(%{assigns: %{auth_state: :logged_in}} = socket) do
    opts = Defaults.opts(socket, types())

    socket
    |> load_processes(opts)
    |> load_process_instances(opts)
    |> assign(:state_opts, opts)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(_params, _url, %{assigns: %{auth_state: :not_logged_in}} = socket) do
    {:noreply, socket}
  end
  def handle_params(params, url, socket) do
    socket
    |> prepare_processes(socket.assigns.current_project.id)
    |> assign(url: URI.parse(url))
    |> do_handle_params(params)
  end

  def do_handle_params(socket, params) do
    {
      :noreply,
      socket
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Process")
    |> assign(:process, Automation.get_process!(String.to_integer(id), socket, socket.assigns.state_opts))
    |> assign(:select_lists, select_lists(socket.assigns.current_team.id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Process")
    |> assign(:process, %Process{})
    |> assign(:select_lists, select_lists(socket.assigns.current_team.id))
  end

  defp apply_action(socket, :index, %{"project_id" => project_id}) do
    project = Projects.get_project!(project_id, socket)
    socket
    |> assign(:page_title, "Listing Processes")
    |> assign(:current_project, project)
    |> prepare_processes(project.id)
    |> assign(:select_lists, select_lists(socket.assigns.current_team.id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Processes")
    |> assign(:process, nil)
  end

  @impl true
  def handle_event("select-project" = n, p, s) do
    {:noreply, socket} = Root.handle_event(n, p, s)
    {:noreply, prepare_processes(socket, socket.assigns.current_project.id)}
  end
  def handle_event("delete", %{"id" => id}, socket) do
    process = Automation.get_process!(id)
    {:ok, _} = Automation.delete_process(process)
    {
      :noreply,
      socket
      |> load_processes(socket.assigns.state_opts)
      |> prepare_processes(process.id)
    }
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info(%{topic: _, event: _, payload: %ProcessInstance{}} = sub_data, socket) do
    Logger.debug("#{__MODULE__} Received a ProcessInstance broadcast")
    {:noreply, socket} = Root.handle_info(sub_data, socket)
    {:noreply, prepare_processes(socket, socket.assigns.current_project.id)}
  end
  def handle_info(p, s), do: Root.handle_info(p, s)

  def select_lists(team_id) do
    %{
      projects:
        Projects.list_projects(%{}, %{team_id: team_id})
        |> Helpers.select_list(:name, false)
    }
  end

  def prepare_processes(socket, project_id) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filter, {:project_id, project_id})
      |> Keyword.put(:order, [%{field: :name, order: :asc}])
      |> Keyword.put(:preloads, [:process_instances])
      |> Keyword.put(:limit,  [process_instances: 5])

    socket
    |> assign(:processes, Automation.list_processes(socket, opts))
  end

  def load_processes(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{user_id: socket.assigns.current_user.id})

    Automation.load_processes(socket, opts)
  end

  def load_process_instances(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{user_id: socket.assigns.current_user.id})

    UserDocs.ProcessInstances.load_user_process_instances(socket, opts)
  end
end
