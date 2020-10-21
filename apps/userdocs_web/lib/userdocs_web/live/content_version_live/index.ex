defmodule UserDocsWeb.ContentVersionLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocs.Documents
  alias UserDocs.Documents.ContentVersion

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> maybe_assign_current_user(session)
      |> assign(:content_versions, list_content_versions())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Content version")
    |> assign(:content_version, Documents.get_content_version!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Content version")
    |> assign(:content_version, %ContentVersion{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Content versions")
    |> assign(:content_version, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    content_version = Documents.get_content_version!(id)
    {:ok, _} = Documents.delete_content_version(content_version)

    {:noreply, assign(socket, :content_versions, list_content_versions())}
  end

  defp list_content_versions do
    Logger.debug("ContentVersionLive.Index querying content versions")
    Documents.list_content_versions(%{language_code: true})
  end
end
