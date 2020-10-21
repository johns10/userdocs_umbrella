defmodule UserDocsWeb.LanguageCodeLive.Index do
  use UserDocsWeb, :live_view

  require Logger

  alias UserDocs.Documents
  alias UserDocs.Documents.LanguageCode

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :language_codes, list_language_codes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Language code")
    |> assign(:language_code, Documents.get_language_code!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Language code")
    |> assign(:language_code, %LanguageCode{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Language codes")
    |> assign(:language_code, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    language_code = Documents.get_language_code!(id)
    {:ok, _} = Documents.delete_language_code(language_code)

    {:noreply, assign(socket, :language_codes, list_language_codes())}
  end

  defp list_language_codes do
    Logger.debug("LanguageCodeLive.Index querying language codes")
    Documents.list_language_codes()
  end
end
