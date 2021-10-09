defmodule UserDocsWeb.JobLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Jobs
  alias UserDocs.Jobs.Job
  alias UserDocsWeb.Root

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, types())
      |> initialize()
    }
  end

  def initialize(%{assigns: %{auth_state: :logged_in}} = socket) do
    socket
    |> load_jobs()
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(params, url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params) |> assign(url: URI.parse(url))}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Job")
    |> assign(:job, Jobs.get_job!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Job")
    |> assign(:job, %Job{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Jobs")
    |> assign(:job, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    job = Jobs.get_job!(id)
    {:ok, _} = Jobs.delete_job(job)

    {:noreply, load_jobs(socket)}
  end

  @impl true
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info(n, p), do: Root.handle_info(n, p)

  def types(), do: [UserDocs.Projects.Project]

  defp load_jobs(socket) do
    socket
    |> assign(:jobs, Jobs.list_jobs(%{filters: [team_id: socket.assigns.current_team.id]}))
  end
end
