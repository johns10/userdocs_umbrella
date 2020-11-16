defmodule UserDocsWeb.DocumentLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Documents
  alias UserDocs.Documents.Document
  alias UserDocsWeb.UserLive

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> UserLive.Helpers.validate_logged_in(session)
      |> assign(:documents, list_documents())
    }
  end

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
    {:ok, _} = Documents.delete_document(document)

    {:noreply, assign(socket, :documents, list_documents())}
  end

  defp list_documents do
    Documents.list_documents()
  end
end
