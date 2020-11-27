defmodule UserDocsWeb.DocumentVersionLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents
  alias UserDocsWeb.Layout
  alias UserDocsWeb.DocumentVersionLive.EventHandlers

  @impl true
  def update(%{document_version: document_version} = assigns, socket) do
    changeset = Documents.change_document_version(document_version)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event(n, p, s), do: EventHandlers.handle_event(n, p, s)
end
