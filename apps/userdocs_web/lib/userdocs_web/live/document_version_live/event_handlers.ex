defmodule UserDocsWeb.DocumentVersionLive.EventHandlers do
  alias Phoenix.LiveView
  alias UserDocs.Documents
  alias UserDocsWeb.Defaults

  def handle_event("delete", %{"id" => id}, socket) do
    document_version = Documents.get_document_version!(id)
    {:ok, deleted_document_version} = Documents.delete_document_version(document_version)
    UserDocsWeb.Endpoint.broadcast(Defaults.channel(socket), "delete", deleted_document_version)

    {:noreply, socket}
  end
  def handle_event("validate", %{"document_version" => document_version_params}, socket) do
    changeset =
      socket.assigns.document_version
      |> Documents.change_document_version(document_version_params)
      |> Map.put(:action, :validate)

    {:noreply, LiveView.assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"document_version" => document_version_params}, socket) do
    save_document_version(socket, socket.assigns.action, document_version_params)
  end

  defp save_document_version(socket, :edit, document_version_params) do
    case Documents.update_document_version(socket.assigns.document_version, document_version_params) do
      {:ok, _document_version} ->
        {:noreply, LiveView.put_flash(socket, :info, "Document Version updated successfully") }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, LiveView.assign(socket, :changeset, changeset)}
    end
  end

  defp save_document_version(socket, :new, document_version_params) do
    case Documents.create_document_version(document_version_params) do
      {:ok, document_version} ->
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "create", document_version)
        {:noreply, LiveView.put_flash(socket, :info, "Document Version created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Failed Save")
        {:noreply, LiveView.assign(socket, changeset: changeset)}
    end
  end
end
