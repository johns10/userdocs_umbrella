defmodule UserDocsWeb.PageLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Web
  alias UserDocs.Web.Page

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :pages, list_pages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Page")
    |> assign(:page, Web.get_page!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Page")
    |> assign(:page, %Page{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pages")
    |> assign(:page, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    page = Web.get_page!(id)
    {:ok, _} = Web.delete_page(page)

    {:noreply, assign(socket, :pages, list_pages())}
  end

  defp list_pages do
    Web.list_pages()
  end
end
