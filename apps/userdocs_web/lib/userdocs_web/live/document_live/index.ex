defmodule UserDocsWeb.DocumentLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Documents
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.DocumentVersion

  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.UserLive.LoginFormComponent

  @impl true
  def mount(params, session, socket) do
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
    |> load_document_versions()
    |> load_documents()
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
    document_version = Documents.get_document_version!(id)
    {:ok, _} = Documents.delete_document_version(document_version)

    {:noreply, socket}
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  def handle_info(n, s), do: Root.handle_info(n, s)

  defp document_versions(document, document_versions) do
    opts = [ data_type: :list, strategy: :by_item ]
    StateHandlers.list(document_versions, DocumentVersion, opts)
  end

  defp load_documents(socket) do
    Documents.load_documents(socket, state_opts())
  end

  defp load_document_versions(socket) do
    opts =
      state_opts()
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_user.default_team_id})

    Documents.load_document_versions(socket, opts)
  end

  defp prepare_documents(socket) do
    assign(socket, :documents, Documents.list_documents(socket, state_opts()))
  end

  defp projects_select_list(socket) do
    projects = socket.assigns.data.projects
    assign(socket, :projects_select, UserDocs.Helpers.select_list(projects, :name, false))
  end

  defp state_opts() do
    Defaults.state_opts()
    |> Keyword.put(:location, :data)
  end
end
