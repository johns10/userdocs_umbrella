defmodule UserDocsWeb.DocumentLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.ChangesetHelpers
  alias UserDocs.Documents
  alias UserDocs.Projects
  alias UserDocs.Projects.Version
  alias UserDocs.Documents.DocumentVersion
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
      |> update_document_version_names(socket)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def update_document_version_names(changeset, socket) do
    case Ecto.Changeset.get_change(changeset, :document_versions, []) do
      [] -> changeset
      [ _ | _ ] = document_versions ->
        document_versions =
          Enum.map(document_versions, fn(dv) ->
            document_name = Ecto.Changeset.get_field(changeset, :name)
            version =
              case Ecto.Changeset.get_field(dv, :version_id) do
                nil -> %Version{ name: "No Version Set"}
                id -> Projects.get_version!(id, socket, socket.assigns.state_opts)
              end
            name = document_name <> " (" <> version.name <> ")"
            Ecto.Changeset.put_change(dv, :name, name)
          end)

        Ecto.Changeset.put_change(changeset, :document_versions, document_versions)
    end
  end

  def handle_event("save", %{"document" => document_params}, socket) do
    save_document(socket, socket.assigns.action, document_params)
  end

  def handle_event("add-document-version", _, socket) do
    changeset = ChangesetHelpers.add_object(
      socket.assigns.changeset,
      socket.assigns.document,
      :document_versions,
      %DocumentVersion{ temp_id: UUID.uuid4() }
    )

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-document-version", %{"remove" => remove_id}, socket) do
    changeset = ChangesetHelpers.remove_object(
      socket.assigns.changeset,
      :document_versions,
      remove_id
    )

    {:noreply, assign(socket, changeset: changeset)}
  end

  defp save_document(socket, :edit, document_params) do
    case Documents.update_document(socket.assigns.document, document_params) do
      {:ok, document} ->
        send(self(), { :broadcast, "update", document })
        send(self(), :close_modal)
        {:noreply, put_flash(socket, :info, "Document updated successfully") }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_document(socket, :new, document_params) do
    case Documents.create_document(document_params) do
      {:ok, document} ->
        send(self(), { :broadcast, "create", document })
        send(self(), :close_modal)
        {:noreply, put_flash(socket, :info, "Document created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Failed Save")
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
