defmodule UserDocsWeb.LanguageCodeLive.Show do
  use UserDocsWeb, :live_view

  alias UserDocs.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:language_code, Documents.get_language_code!(id))}
  end

  defp page_title(:show), do: "Show Language code"
  defp page_title(:edit), do: "Edit Language code"
end
