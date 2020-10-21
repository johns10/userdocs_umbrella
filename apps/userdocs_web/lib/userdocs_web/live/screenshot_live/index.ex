defmodule UserDocsWeb.ScreenshotLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Media
  alias UserDocs.Media.Screenshot

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :screenshots, list_screenshots())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Screenshot")
    |> assign(:screenshot, Media.get_screenshot!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Screenshot")
    |> assign(:screenshot, %Screenshot{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Screenshots")
    |> assign(:screenshot, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    screenshot = Media.get_screenshot!(id)
    {:ok, _} = Media.delete_screenshot(screenshot)

    {:noreply, assign(socket, :screenshots, list_screenshots())}
  end

  defp list_screenshots do
    Media.list_screenshots()
  end
end
