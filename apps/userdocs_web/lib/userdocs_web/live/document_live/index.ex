defmodule UserDocsWeb.DocumentLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Documents
  alias UserDocs.Projects
  alias UserDocs.Helpers
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.DocumentVersion

  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Loaders


  def types() do
    [
      UserDocs.Documents.Document,
      UserDocs.Documents.DocumentVersion,
      UserDocs.Projects.Version,
      UserDocs.Projects.Project,
      UserDocs.Users.Team
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
    |> load_document_versions()
    |> load_documents()
    |> Loaders.versions()
    |> Loaders.projects()
    |> prepare_documents()
    |> projects_select_list()
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Document")
    |> assign(:document, Documents.get_document!(id, %{ document_versions: true }))
    |> assign(:select_lists, select_lists(socket))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Document")
    |> assign(:document, %Document{})
    |> assign(:select_lists, select_lists(socket))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Documents")
    |> assign(:document, nil)
  end

  def select_lists(socket) do
    %{
      projects:
        Projects.list_projects(socket, socket.assigns.state_opts)
        |> Helpers.select_list(:name, false),
      versions:
        Projects.list_versions(socket, socket.assigns.state_opts)
        |> Helpers.select_list(:name, false),
    }
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document = Documents.get_document!(id)
    {:ok, deleted_document} = Documents.delete_document(document)
    UserDocsWeb.Endpoint.broadcast(Defaults.channel(socket), "delete", deleted_document)
    {:noreply, socket}
  end
  def handle_event("select-version" = n, p, s) do
    { :noreply, socket } = Root.handle_event(n, p, s)
    { :noreply, prepare_documents(socket) }
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info(%{topic: _, event: _, payload: %DocumentVersion{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_documents(socket) }
  end
  def handle_info(%{topic: _, event: _, payload: %Document{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_documents(socket) }
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  defp load_documents(socket) do
    opts = Keyword.put(socket.assigns.state_opts, :filters, %{project_id: socket.assigns.current_project.id})

    Documents.load_documents(socket, opts)
  end

  defp load_document_versions(socket) do
    opts = Keyword.put(socket.assigns.state_opts, :filters, %{team_id: socket.assigns.current_team.id})

    Documents.load_document_versions(socket, opts)
  end

  defp prepare_documents(socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filter, { :project_id, socket.assigns.current_project.id })
      |> Keyword.put(:preloads, [ :document_versions, [ document_versions: :version ] ])
      |> Keyword.put(:order, [ %{ field: :id, order: :asc } ])

    assign(socket, :documents, Documents.list_documents(socket, opts))
  end

  defp projects_select_list(socket) do
    projects = Projects.list_projects(socket, socket.assigns.state_opts)
    socket
    |> assign(:projects_select, UserDocs.Helpers.select_list(projects, :name, false))
  end
end
