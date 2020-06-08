defmodule UserDocsWeb.ElementLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Web
  alias UserDocs.Web.Element

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :elements, list_elements())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Element")
    |> assign(:element, Web.get_element!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Element")
    |> assign(:element, %Element{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Elements")
    |> assign(:element, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    element = Web.get_element!(id)
    {:ok, _} = Web.delete_element(element)

    {:noreply, assign(socket, :elements, list_elements())}
  end

  defp list_elements do
    Web.list_elements()
  end
end
