defmodule UserDocsWeb.FileLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Media
  alias UserDocs.Media.File

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :files, list_files())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit File")
    |> assign(:file, Media.get_file!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New File")
    |> assign(:file, %File{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Files")
    |> assign(:file, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    file = Media.get_file!(id)
    {:ok, _} = Media.delete_file(file)

    {:noreply, assign(socket, :files, list_files())}
  end

  defp list_files do
    Media.list_files()
  end
end
