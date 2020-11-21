defmodule UserDocsWeb.DocumentLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Documents
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
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Document")
    |> assign(:document_version, Documents.get_document_version!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Document")
    |> assign(:document_version, %DocumentVersion{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Documents")
    |> assign(:document_version, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document_version = Documents.get_document_version!(id)
    {:ok, _} = Documents.delete_document_version(document_version)

    {:noreply, socket}
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  def handle_info(n, s), do: Root.handle_info(n, s)

  defp load_document_versions(socket) do
    filters = %{team_id: socket.assigns.current_user.default_team_id}
    Documents.load_document_versions(socket, %{}, filters, Defaults.state_opts())
  end
end
