defmodule UserDocsWeb.FileLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Media

  @impl true
  def update(%{file: file} = assigns, socket) do
    changeset = Media.change_file(file)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"file" => file_params}, socket) do
    changeset =
      socket.assigns.file
      |> Media.change_file(file_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"file" => file_params}, socket) do
    save_file(socket, socket.assigns.action, file_params)
  end

  defp save_file(socket, :edit, file_params) do
    case Media.update_file(socket.assigns.file, file_params) do
      {:ok, _file} ->
        {:noreply,
         socket
         |> put_flash(:info, "File updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_file(socket, :new, file_params) do
    case Media.create_file(file_params) do
      {:ok, _file} ->
        {:noreply,
         socket
         |> put_flash(:info, "File created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
