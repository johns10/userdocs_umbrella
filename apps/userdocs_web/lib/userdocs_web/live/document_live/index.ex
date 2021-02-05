defmodule UserDocsWeb.DocumentLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Documents
  alias UserDocs.Projects
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.DocumentVersion

  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults

  defp base_opts() do
    Defaults.state_opts()
    |> Keyword.put(:location, :data)
  end

  defp state_opts(socket) do
    base_opts()
    |> Keyword.put(:broadcast, true)
    |> Keyword.put(:channel, UserDocsWeb.Defaults.channel(socket))
    |> Keyword.put(:broadcast_function, &UserDocsWeb.Endpoint.broadcast/3)
  end

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize()
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    socket
    |> (&(assign(&1, :data, Map.put(&1.assigns.data, :documents, [])))).()
    |> (&(assign(&1, :data, Map.put(&1.assigns.data, :document_versions, [])))).()
    |> load_document_versions()
    |> load_documents()
    |> prepare_documents()
    |> projects_select_list()
    |> assign(:state_opts, state_opts(socket))
    |> StateHandlers.inspect(state_opts(socket))
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Document")
    |> assign(:document, Documents.get_document!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Document")
    |> assign(:document, %Document{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Documents")
    |> assign(:document, nil)
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
  def handle_event("edit-document" = n, %{ "id" => id }, socket) do
    params =
      %{}
      |> Map.put(:document_id, String.to_integer(id))
      |> Map.put(:team, UserDocs.Users.get_team!(socket.assigns.current_team_id, socket, state_opts(socket)))
      |> Map.put(:projects, socket.assigns.data.projects)
      |> Map.put(:channel, Defaults.channel(socket))
      |> Map.put(:opts, state_opts(socket))

    Root.handle_event(n, params, socket)
  end
  def handle_event("new-document" = n, _params, socket) do
    params =
      %{}
      |> Map.put(:team, UserDocs.Users.get_team!(socket.assigns.current_team_id, socket, state_opts(socket)))
      |> Map.put(:projects, socket.assigns.data.projects)
      |> Map.put(:channel, Defaults.channel(socket))
      |> Map.put(:state_opts, state_opts(socket))

    Root.handle_event(n, params, socket)
  end
  def handle_event("new-document-version" = n, %{ "document-id" => id }, socket) do
    params =
      %{}
      |> Map.put(:document_id, String.to_integer(id))
      |> Map.put(:version_id, socket.assigns.current_version_id)
      |> Map.put(:documents, socket.assigns.data.documents)
      |> Map.put(:versions, socket.assigns.data.versions)
      |> Map.put(:state_opts, state_opts(socket))

    Root.handle_event(n, params, socket)
  end
  def handle_event("edit-document-version" = n, %{ "id" => id }, socket) do
    params =
      %{}
      |> Map.put(:document_id, String.to_integer(id))
      |> Map.put(:document_version_id, String.to_integer(id))
      |> Map.put(:version_id, socket.assigns.current_version_id)
      |> Map.put(:documents, socket.assigns.data.documents)
      |> Map.put(:document_versions, socket.assigns.data.document_versions)
      |> Map.put(:versions, socket.assigns.data.versions)
      |> Map.put(:opts, state_opts(socket))

    Root.handle_event(n, params, socket)
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

  defp document_versions(_document, document_versions) do
    opts = [ data_type: :list, strategy: :by_item ]
    StateHandlers.list(document_versions, DocumentVersion, opts)
  end

  defp load_documents(socket) do
    opts =
      state_opts(socket)
      |> Keyword.put(:filters, %{project_id: socket.assigns.current_project_id})

    Documents.load_documents(socket, opts)
  end

  defp load_document_versions(socket) do
    IO.puts("Loading document versions")
    opts =
      state_opts(socket)
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team_id})

    Documents.load_document_versions(socket, opts)
  end

  defp prepare_documents(socket) do
    IO.puts("Preparing Document Versions")
    opts =
      state_opts(socket)
      |> Keyword.put(:filter, { :project_id, socket.assigns.current_project_id })
      |> Keyword.put(:preloads, [ :document_versions, [ document_versions: :version ] ])
      |> Keyword.put(:order, [ %{ field: :id, order: :asc } ])

    assign(socket, :documents, Documents.list_documents(socket, opts))
  end

  defp projects_select_list(socket) do
    projects = Projects.list_projects(socket, state_opts(socket))
    socket
    |> assign(:projects_select, UserDocs.Helpers.select_list(projects, :name, false))
  end
end
