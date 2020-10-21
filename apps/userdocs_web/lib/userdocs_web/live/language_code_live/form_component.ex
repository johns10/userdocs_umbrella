defmodule UserDocsWeb.LanguageCodeLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents

  @impl true
  def update(%{language_code: language_code} = assigns, socket) do
    changeset = Documents.change_language_code(language_code)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"language_code" => language_code_params}, socket) do
    changeset =
      socket.assigns.language_code
      |> Documents.change_language_code(language_code_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"language_code" => language_code_params}, socket) do
    save_language_code(socket, socket.assigns.action, language_code_params)
  end

  defp save_language_code(socket, :edit, language_code_params) do
    case Documents.update_language_code(socket.assigns.language_code, language_code_params) do
      {:ok, _language_code} ->
        {:noreply,
         socket
         |> put_flash(:info, "Language code updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_language_code(socket, :new, language_code_params) do
    case Documents.create_language_code(language_code_params) do
      {:ok, _language_code} ->
        {:noreply,
         socket
         |> put_flash(:info, "Language code created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
