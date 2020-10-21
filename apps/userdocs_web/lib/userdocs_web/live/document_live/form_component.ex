defmodule UserDocsWeb.DocumentLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents

  @impl true
  def update(%{document: document} = assigns, socket) do
    changeset = Documents.change_document(document)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
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
      {:ok, _document} ->
        {:noreply,
         socket
         |> put_flash(:info, "Document updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  # This clause adds the default empty document body when creating a new document
  # with an empty body
  defp save_document(socket, :new, document_params = %{ "body" => ""}) do
    save_document(socket, :new,
      Map.put(document_params, "body", Documents.Document.default_body))
  end
  defp save_document(socket, :new, document_params) do
    case Documents.create_document(document_params) do
      {:ok, _document} ->
        {:noreply,
         socket
         |> put_flash(:info, "Document created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Failed Save")
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
