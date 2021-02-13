defmodule UserDocsWeb.DocubitLive.EventHandlers do
  alias Phoenix.LiveView
  alias UserDocs.Documents
  alias UserDocsWeb.Defaults

  def handle_event("delete", %{"id" => id}, socket) do
    docubit = Documents.get_docubit!(id)
    {:ok, deleted_docubit } = Documents.delete_docubit(docubit)
    UserDocsWeb.Endpoint.broadcast(Defaults.channel(socket), "delete", deleted_docubit)
    {:noreply, socket}
  end
  def handle_event("validate", %{"docubit" => docubit_params}, socket) do
    changeset =
      socket.assigns.docubit
      |> Documents.change_docubit(docubit_params)
      |> Map.put(:action, :validate)

    {:noreply, LiveView.assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"docubit" => docubit_params}, socket) do
    save_docubit(socket, socket.assigns.action, docubit_params)
  end

  defp save_docubit(socket, :new, docubit_params) do
    case Documents.create_docubit(docubit_params) do
      {:ok, docubit} ->
        send(self(), :close_modal)
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "create", docubit)
        {:noreply, LiveView.put_flash(socket, :info, "Document created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Failed Save")
        {:noreply, LiveView.assign(socket, changeset: changeset)}
    end
  end
end
