defmodule UserDocsWeb.DocumentVersionLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents
  alias UserDocs.Documents.DocumentVersion
  alias UserDocsWeb.Layout

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
  def handle_event("validate", %{"document_version" => document_version_params}, socket) do
    changeset =
      socket.assigns.document_version
      |> Documents.change_document_version(document_version_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"document_version" => document_version_params}, socket) do
    save_document_version(socket, socket.assigns.action, document_version_params)
  end

  defp save_document_version(socket, :edit, document_version_params) do
    case Documents.update_document_version(socket.assigns.document_version, document_version_params) do
      {:ok, _document_version} ->
        send(self(), :close_modal)
        {:noreply, put_flash(socket, :info, "Document Version updated successfully") }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_document_version(socket, :new, document_version_params) do
    case Documents.create_document_version(document_version_params) do
      {:ok, document_version} ->
        send(self(), :close_modal)
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "create", document_version)
        {:noreply, put_flash(socket, :info, "Document Version created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Failed Save")
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
