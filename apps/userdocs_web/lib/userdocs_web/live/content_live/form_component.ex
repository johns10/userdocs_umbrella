defmodule UserDocsWeb.ContentLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents

  @impl true
  def update(%{content: content} = assigns, socket) do
    changeset = Documents.change_content(content)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"content" => content_params}, socket) do
    changeset =
      socket.assigns.content
      |> Documents.change_content(content_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"content" => content_params}, socket) do
    save_content(socket, socket.assigns.action, content_params)
  end

  defp save_content(socket, :edit, content_params) do
    case Documents.update_content(socket.assigns.content, content_params) do
      {:ok, _content} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_content(socket, :new, content_params) do
    case Documents.create_content(content_params) do
      {:ok, _content} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
