defmodule UserDocsWeb.DocumentLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Documents
  alias UserDocs.Documents.DocumentVersion
  alias UserDocsWeb.UserLive

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> UserLive.Helpers.validate_logged_in(session)
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    socket
    |> (&(assign(&1, :document_versions, list_document_versions(&1.assigns.current_user.default_team_id)))).()
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

    {:noreply, assign(socket, :document_versions, list_document_versions(socket.assigns.current_user.default_team_id))}
  end

  # TODO: Probably set the current team ID somewhere in the app
  defp list_document_versions(team_id) do
    Documents.list_document_versions(%{}, %{team_id: team_id})
  end
end
