defmodule UserDocsWeb.DocumentLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents
  alias UserDocs.Documents.Document
  alias UserDocsWeb.Layout

  @impl true
  def update(%{document: document} = assigns, socket) do
    changeset = Documents.change_document(document)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"document" => document_params}, socket) do
    changeset =
      socket.assigns.document
      |> Documents.change_document(document_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"document" => document_params}, socket) do
    save_document(socket, socket.assigns.action, document_params)
  end

  defp save_document(socket, :edit, document_params) do
    case Documents.update_document(socket.assigns.document, document_params) do
      {:ok, document} ->
        send(self(), :close_modal)
        {:noreply, put_flash(socket, :info, "Document updated successfully") }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_document(socket, :new, document_params) do
    case Documents.create_document(document_params) do
      {:ok, document} ->
        send(self(), :close_modal)
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "create", document)
        {:noreply, put_flash(socket, :info, "Document created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Failed Save")
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
