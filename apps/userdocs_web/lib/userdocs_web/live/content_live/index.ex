defmodule UserDocsWeb.ContentLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Documents
  alias UserDocs.Documents.Content

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> maybe_assign_current_user(session)
      |> assign(:content_collection, list_content())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Content")
    |> assign(:content, Documents.get_content!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Content")
    |> assign(:content, %Content{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Content")
    |> assign(:content, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    content = Documents.get_content!(id)
    {:ok, _} = Documents.delete_content(content)

    {:noreply, assign(socket, :content_collection, list_content())}
  end

  defp list_content do
    Documents.list_content()
  end
end
